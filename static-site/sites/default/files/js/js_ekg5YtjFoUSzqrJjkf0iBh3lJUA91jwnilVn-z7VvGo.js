/* @license GPL-2.0-or-later https://www.drupal.org/licensing/faq */
var i=Object.defineProperty;var _=(n,e,m)=>e in n?i(n,e,{enumerable:!0,configurable:!0,writable:!0,value:m}):n[e]=m;var r=(n,e,m)=>_(n,typeof e!="symbol"?e+"":e,m);class s{constructor(e){r(this,"primary_menu_wrapper_element");r(this,"primary_menu_element");r(this,"primary_menu_container");r(this,"open_menu_element");r(this,"close_menu_element");this.primary_menu_wrapper_element=e,this.primary_menu_element=e.querySelector(".primary-menu"),this.primary_menu_container=e.querySelector(".primary-menu-container"),this.open_menu_element=e.querySelector(".js-open-menu"),this.close_menu_element=e.querySelector(".js-close-menu"),!(!this.close_menu_element||!this.primary_menu_element||!this.open_menu_element||!this.primary_menu_container)&&(this.close_menu_element.addEventListener("click",()=>{this.primary_menu_element.classList.add("hidden"),this.primary_menu_container.classList.remove("container");}),this.open_menu_element.addEventListener("click",()=>{this.primary_menu_element.classList.remove("hidden"),this.primary_menu_container.classList.add("container");}));}}const t=document.querySelector(".primary-menu-wrapper");t&&new s(t);;