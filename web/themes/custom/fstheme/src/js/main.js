import '../css/main.pcss'

class PrimaryMenu {

  primary_menu_wrapper_element;
  primary_menu_element;
  primary_menu_container;
  open_menu_element;
  close_menu_element;
  

  constructor(element) {
    this.primary_menu_wrapper_element = element;
    this.primary_menu_element = element.querySelector('.primary-menu');
    this.primary_menu_container = element.querySelector('.primary-menu-container');
    this.open_menu_element = element.querySelector('.js-open-menu');
    this.close_menu_element = element.querySelector('.js-close-menu');

    if (!this.close_menu_element || !this.primary_menu_element || !this.open_menu_element || !this.primary_menu_container) {
      return;
    }

    this.close_menu_element.addEventListener('click', () => {
      this.primary_menu_element.classList.add('hidden');
      this.primary_menu_container.classList.remove('container');
    });

    this.open_menu_element.addEventListener('click', () => {
      this.primary_menu_element.classList.remove('hidden');
      this.primary_menu_container.classList.add('container');
    });
  }
}

const primary_menu_element = document.querySelector('.primary-menu-wrapper');
if (primary_menu_element) {
  new PrimaryMenu(primary_menu_element);
}