document.addEventListener("DOMContentLoaded", function() {
  'use strict';

  var html = document.querySelector('html'),
    globalWrap = document.querySelector('.global-wrap'),
    body = document.querySelector('body'),
    toggleTheme = document.querySelector(".toggle-theme"),
    btnScrollToTop = document.querySelector(".top");


  /* =======================================================
  // Theme Switcher
  ======================================================= */
  if (toggleTheme) {
    toggleTheme.addEventListener("click", () => {
      darkMode();
    });
  };

  function darkMode() {
    if (html.classList.contains('dark-mode')) {
      html.classList.remove('dark-mode');
      localStorage.removeItem("theme");
      document.documentElement.removeAttribute("dark");
    } else {
      html.classList.add('dark-mode');
      localStorage.setItem("theme", "dark");
      document.documentElement.setAttribute("dark", "");
    }
  };


  // =====================
  // Simple Jekyll Search
  // =====================
  SimpleJekyllSearch({
    searchInput: document.getElementById("js-search-input"),
    resultsContainer: document.getElementById("js-results-container"),
    json: "/search.json",
    searchResultTemplate: '<div class="search-results__item"><a href="{url}" class="search-results__image" style="background-image: url({image})"></a> <a href="{url}" class="search-results__link"><time class="search-results-date" datetime="{date}">{date}</time><div class="search-results-title">{title}</div></a></div>',
    noResultsText: '<h4 class="no-results">No results found</h4>'
  });


  /* ================================================================
  // Stop Animations During Window Resizing and Switching Theme Modes
  ================================================================ */
  let disableTransition;

  if (toggleTheme) {
    toggleTheme.addEventListener("click", () => {
      stopAnimation();
    });

    window.addEventListener("resize", () => {
      stopAnimation();
    });

    function stopAnimation() {
      document.body.classList.add("disable-animation");
      clearTimeout(disableTransition);
      disableTransition = setTimeout(() => {
        document.body.classList.remove("disable-animation");
      }, 100);
    }
  }


  /* =======================
  // Responsive Videos
  ======================= */
  reframe(".post__content iframe:not(.reframe-off), .page__content iframe:not(.reframe-off)");


  /* =======================
  // LazyLoad Images
  ======================= */
  var lazyLoadInstance = new LazyLoad({
    elements_selector: ".lazy"
  })


  /* =======================
  // Zoom Image
  ======================= */
  const lightense = document.querySelector(".page__content img, .post__content img, .gallery__image img"),
  imageLink = document.querySelectorAll(".page__content a img, .post__content a img, .gallery__image a img");

  if (imageLink) {
    for (var i = 0; i < imageLink.length; i++) imageLink[i].parentNode.classList.add("image-link");
    for (var i = 0; i < imageLink.length; i++) imageLink[i].classList.add("no-lightense");
  }

  if (lightense) {
    Lightense(".page__content img:not(.no-lightense), .post__content img:not(.no-lightense), .gallery__image img:not(.no-lightense)", {
    padding: 60,
    offset: 30
    });
  }


  /* =======================
  // Scroll Top Button
  ======================= */
  window.addEventListener("scroll", function () {
    window.scrollY > window.innerHeight ? btnScrollToTop.classList.add("is-active") : btnScrollToTop.classList.remove("is-active");
  });

  btnScrollToTop.addEventListener("click", function () {
    if (window.scrollY != 0) {
      window.scrollTo({
        top: 0,
        right: 0,
        behavior: "smooth"
      })
    }
  });


  /* =======================
  // Custom Cursor (دو دایره رینگ – کلیک = دایره بیرونی بزرگ‌تر)
  ======================= */
  if (window.matchMedia && window.matchMedia("(pointer: fine)").matches) {
    var cursorStyles = document.createElement("style");
    cursorStyles.textContent =
      ".has-custom-cursor, .has-custom-cursor * { cursor: none !important; }\n" +
      ".custom-cursor { position: fixed; left: 0; top: 0; width: 0; height: 0; pointer-events: none; z-index: 99999; }\n" +
      ".custom-cursor__inner { position: fixed; width: 10px; height: 10px; border-radius: 50%; background: var(--brand-color, #ff009f); transform: translate(-50%, -50%); box-sizing: border-box; }\n" +
      ".custom-cursor__outer { position: fixed; width: 36px; height: 36px; border-radius: 50%; border: 2px solid var(--brand-color, #ff009f); transform: translate(-50%, -50%); box-sizing: border-box; transition: width 0.2s ease, height 0.2s ease; }\n" +
      ".custom-cursor.is-pressed .custom-cursor__outer { width: 52px; height: 52px; }\n";
    document.head.appendChild(cursorStyles);

    var cursor = document.createElement("div");
    cursor.className = "custom-cursor";
    cursor.setAttribute("aria-hidden", "true");
    cursor.innerHTML = '<span class="custom-cursor__inner"></span><span class="custom-cursor__outer"></span>';
    document.body.appendChild(cursor);

    var curX = 0, curY = 0;
    var inner = cursor.querySelector(".custom-cursor__inner");
    var outer = cursor.querySelector(".custom-cursor__outer");

    function moveCursor(e) {
      curX = e.clientX;
      curY = e.clientY;
    }
    function tick() {
      if (inner) { inner.style.left = curX + "px"; inner.style.top = curY + "px"; }
      if (outer) { outer.style.left = curX + "px"; outer.style.top = curY + "px"; }
      requestAnimationFrame(tick);
    }
    document.addEventListener("mousemove", moveCursor, { passive: true });
    requestAnimationFrame(tick);

    document.addEventListener("mousedown", function () { cursor.classList.add("is-pressed"); });
    document.addEventListener("mouseup", function () { cursor.classList.remove("is-pressed"); });

    document.body.classList.add("has-custom-cursor");
  }

});