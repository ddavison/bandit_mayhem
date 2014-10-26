(function() {
  var Map;

  Map = (function() {
    var constructor;

    function Map() {}

    Map.prototype.width = null;

    Map.prototype.height = null;

    constructor = function(width, height) {
      this.width = width;
      return this.height = height;
    };

    return Map;

  })();

}).call(this);
