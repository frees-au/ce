const contactForm = document.querySelector('[data-contact-form]');

if (contactForm) {
  const status = contactForm.querySelector('[data-contact-status]');

  window.onContactFormSubmit = () => contactForm.submit();

  const script = document.createElement('script');
  script.src = 'https://www.google.com/recaptcha/api.js';
  script.async = true;
  script.defer = true;
  script.addEventListener('error', () => {
    if (status) {
      status.textContent = 'The verification service could not be loaded. Please refresh the page and try again.';
      status.classList.add('text-fs-red');
      status.setAttribute('role', 'alert');
    }
  }, { once: true });
  document.head.append(script);
}
