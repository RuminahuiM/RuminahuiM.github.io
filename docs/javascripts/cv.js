/* Lebenslauf: linke Spalte (aside.cv-side) "klebt" beim Scrollen.
   Ist sie hoeher als das Fenster, scrollt sie zuerst mit, bis ihr Ende
   sichtbar ist, und bleibt erst dann stehen (negativer Abstand oben).
   Ohne JavaScript scrollt die Spalte einfach mit der Seite. */
(function () {
  function fit() {
    document.querySelectorAll(".cv-side").forEach(function (side) {
      var header = document.querySelector(".pf-header");
      var h = header ? header.getBoundingClientRect().height : 0;
      side.style.top = Math.min(h, window.innerHeight - side.offsetHeight) + "px";
      side.classList.add("cv-side--sticky");
    });
  }
  function init() {
    if (!document.querySelector(".cv-side")) return;
    fit();
    window.addEventListener("resize", fit);
    window.addEventListener("load", fit);   /* nach dem Laden von Foto und Schrift */
  }
  if (window.document$ && typeof window.document$.subscribe === "function") {
    window.document$.subscribe(init);
  } else if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", init);
  } else {
    init();
  }
})();
