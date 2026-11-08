/* Setzt E-Mail-Links erst im Browser zusammen, damit die Adresse nicht im
   Klartext im HTML steht (Schutz vor einfachen Adress-Crawlern).
   Erwartet: <a class="js-mail" data-m="BASE64(umgekehrte Adresse)">. */
(function () {
  function decode(token) {
    try { return atob(token).split("").reverse().join(""); } catch (e) { return ""; }
  }
  function init() {
    document.querySelectorAll("a.js-mail[data-m]").forEach(function (a) {
      var addr = decode(a.getAttribute("data-m"));
      if (!addr || addr.indexOf("@") < 1) return;
      a.href = "mailto:" + addr;
      if (a.textContent === "E-Mail schreiben") a.textContent = addr;
      a.removeAttribute("data-m");
    });
  }
  if (window.document$ && typeof window.document$.subscribe === "function") {
    window.document$.subscribe(init);   /* Material: auch nach Seitenwechsel */
  } else if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", init);
  } else {
    init();
  }
})();
