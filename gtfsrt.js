/* Tiny GTFS-realtime decoder: just enough to read upcoming arrivals at given stops.
   FeedMessage.entity(2) -> FeedEntity.trip_update(3) -> TripUpdate.trip(1){route_id(5)}, stop_time_update(2){stop_id(4), arrival(2){time(2)}, departure(3){time(2)}} */
(function (root) {
  function Reader(buf, start, end) { this.b = buf; this.p = start || 0; this.end = end === undefined ? buf.length : end; }
  Reader.prototype.varint = function () {
    var result = 0, mul = 1, byte;
    do { byte = this.b[this.p++]; result += (byte & 0x7f) * mul; mul *= 128; } while (byte & 0x80 && this.p < this.end);
    return result;
  };
  Reader.prototype.skip = function (wt) {
    if (wt === 0) this.varint(); else if (wt === 1) this.p += 8; else if (wt === 2) { var n = this.varint(); this.p += n; } else if (wt === 5) this.p += 4;
    else throw new Error("wire type " + wt);
  };
  // Calls fn(fieldNumber, wireType, reader) for each field; length-delimited fields get a sub-reader.
  function fields(r, fn) {
    while (r.p < r.end) {
      var key = r.varint(), f = Math.floor(key / 8), wt = key % 8;
      if (wt === 2) { var len = r.varint(), sub = new Reader(r.b, r.p, r.p + len); r.p += len; fn(f, wt, sub); }
      else { var before = r.p; fn(f, wt, r); if (r.p === before) r.skip(wt); }
    }
  }
  function str(r) { var s = ""; for (var i = r.p; i < r.end; i++) s += String.fromCharCode(r.b[i]); return s; }
  function eventTime(r) { var t = 0; fields(r, function (f, wt, x) { if (f === 2 && wt === 0) t = x.varint(); }); return t; }

  /* Returns { "G26N": [{route, time}, ...], ... } for the requested stop ids, sorted by time (unix seconds). */
  function arrivals(bytes, stopIds) {
    var want = {}, out = {};
    stopIds.forEach(function (s) { want[s] = 1; out[s] = []; });
    fields(new Reader(bytes), function (f, wt, ent) {
      if (f !== 2 || wt !== 2) return;
      fields(ent, function (f2, wt2, tu) {
        if (f2 !== 3 || wt2 !== 2) return;
        var route = "", stops = [];
        fields(tu, function (f3, wt3, x) {
          if (f3 === 1 && wt3 === 2) fields(x, function (f4, wt4, y) { if (f4 === 5 && wt4 === 2) route = str(y); });
          else if (f3 === 2 && wt3 === 2) {
            var sid = "", arr = 0, dep = 0;
            fields(x, function (f4, wt4, y) {
              if (f4 === 4 && wt4 === 2) sid = str(y);
              else if (f4 === 2 && wt4 === 2) arr = eventTime(y);
              else if (f4 === 3 && wt4 === 2) dep = eventTime(y);
            });
            if (want[sid]) stops.push({ stop: sid, time: arr || dep });
          }
        });
        stops.forEach(function (s) { if (s.time) out[s.stop].push({ route: route, time: s.time }); });
      });
    });
    Object.keys(out).forEach(function (k) { out[k].sort(function (a, b) { return a.time - b.time; }); });
    return out;
  }
  root.GTFSRT = { arrivals: arrivals };
  if (typeof module !== "undefined") module.exports = root.GTFSRT;
})(typeof window !== "undefined" ? window : this);
