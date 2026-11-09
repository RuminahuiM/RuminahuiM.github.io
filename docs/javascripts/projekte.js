/* Karussell der Projektseite (HTML aus hooks/projects.py).
   - Pfeile blaettern um eine Karte, Pfeiltasten und Wischen gehen nativ
     (die Kartenreihe ist ein scrollbarer Bereich mit Scroll-Snap).
   - Filter blendet Karten anderer Kategorien aus.
   - Fortschrittsbalken und "1 von 6" folgen der Scrollposition. */
(function () {
  function setup(root) {
    if (root.dataset.ready) return;
    root.dataset.ready = "1";
    var track = root.querySelector(".pf-carousel__track");
    var bar = root.querySelector(".pf-progress i");
    var count = root.querySelector(".pf-count");
    var prev = root.querySelector('.pf-arrow[data-dir="-1"]');
    var next = root.querySelector('.pf-arrow[data-dir="1"]');
    var tpl = root.getAttribute("data-count") || "{i} / {n}";

    function cards() {
      return Array.prototype.filter.call(track.children, function (c) { return !c.hidden; });
    }
    function step() {
      var list = cards();
      if (list.length < 2) return track.clientWidth;
      return list[1].offsetLeft - list[0].offsetLeft;
    }
    function update() {
      var list = cards();
      var max = track.scrollWidth - track.clientWidth;
      var pos = track.scrollLeft;
      var start = list.length ? list[0].offsetLeft : 0;
      var idx = 0;
      list.forEach(function (c, i) { if (c.offsetLeft - start <= pos + 8) idx = i; });
      if (max > 0 && pos >= max - 8) idx = list.length - 1;   /* ganz rechts: letzte Karte */
      if (count) count.textContent = tpl.replace("{i}", list.length ? idx + 1 : 0).replace("{n}", list.length);
      if (bar) {
        var w = track.scrollWidth ? track.clientWidth / track.scrollWidth : 1;
        w = Math.min(1, Math.max(w, 0.08));
        bar.style.width = (w * 100) + "%";
        bar.style.left = (max > 0 ? (pos / max) * (1 - w) * 100 : 0) + "%";
      }
      if (prev) prev.disabled = pos <= 4;
      if (next) next.disabled = max <= 4 || pos >= max - 4;
      list.forEach(function (c, i) { c.classList.toggle("is-current", i === idx); });
    }
    function go(dir) {
      track.scrollBy({ left: dir * step(), behavior: "smooth" });
    }
    if (prev) prev.addEventListener("click", function () { go(-1); });
    if (next) next.addEventListener("click", function () { go(1); });
    track.addEventListener("scroll", function () { window.requestAnimationFrame(update); }, { passive: true });
    window.addEventListener("resize", update);

    root.querySelectorAll(".pf-pill").forEach(function (pill) {
      pill.addEventListener("click", function () {
        var f = pill.getAttribute("data-filter");
        root.querySelectorAll(".pf-pill").forEach(function (p) {
          p.setAttribute("aria-pressed", p === pill ? "true" : "false");
        });
        Array.prototype.forEach.call(track.children, function (c) {
          c.hidden = !(f === "all" || c.getAttribute("data-cat") === f);
        });
        track.scrollLeft = 0;
        update();
      });
    });
    update();
  }
  function init() {
    document.querySelectorAll(".pf-carousel").forEach(setup);
  }
  if (window.document$ && typeof window.document$.subscribe === "function") {
    window.document$.subscribe(init);
  } else if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", init);
  } else {
    init();
  }
})();
