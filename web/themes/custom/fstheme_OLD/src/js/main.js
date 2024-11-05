import '../css/main.pcss'

// A very simple and poorly written placeholder for opening the menu on mobile.

document.addEventListener('DOMContentLoaded', function() {
  document.querySelector('.fs-toggle-menu').addEventListener('click', function(event) {
    event.preventDefault(); // Prevent the default anchor action
    const menu = document.querySelector('.layout-nav');

    if (menu.classList.contains('hidden')) {
      menu.classList.remove('hidden', 'opacity-0');
      menu.classList.add('animate-slideIn');
    }
    else {
      menu.classList.add('hidden', 'opacity-0');
      menu.classList.remove('animate-slideIn');

    }
  });
});
