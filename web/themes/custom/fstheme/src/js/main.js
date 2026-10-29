import '../css/tailwind.css'
import '../css/core-fixes.css'

/**
 * Override search_api_lunr
 */
Drupal.theme.searchApiLunrResult = function (document) {
  return `<div class="search-api-lunr-teaser">
    <h3 class="mt-4"><a href="${document.getUrl()}">${document.getLabel()}</a></h3>
    ${document.getSummary()}
  </div>
`;
};

class PrimaryMenu {

  primary_menu_wrapper_element;
  primary_menu_element;
  primary_menu_container;
  open_menu_element;
  close_menu_element;


  constructor(element) {
    this.primary_menu_wrapper_element = element;
    this.primary_menu_element = element.querySelector('.primary-menu');
    this.primary_menu_container = element.querySelector('.primary-menu__content');
    this.open_menu_element = element.querySelector('.js-open-menu');
    this.close_menu_element = element.querySelector('.js-close-menu');

    if (!this.close_menu_element || !this.primary_menu_element || !this.open_menu_element || !this.primary_menu_container) {
      return;
    }

    this.close_menu_element.addEventListener('click', () => {
      this.primary_menu_element.classList.add('hidden');
      this.primary_menu_container.classList.remove('page-default-container-span');
    });

    this.open_menu_element.addEventListener('click', () => {
      this.primary_menu_element.classList.remove('hidden');
      this.primary_menu_container.classList.add('page-default-container-span');
    });
  }
}

const primary_menu_element = document.querySelector('.primary-menu-wrapper');
if (primary_menu_element) {
  new PrimaryMenu(primary_menu_element);
}

const contactForm = document.querySelector('[data-contact-form]');

if (contactForm) {
  const endpoint = contactForm.dataset.endpoint;
  const siteKey = contactForm.dataset.recaptchaSiteKey;
  const submitButton = contactForm.querySelector('[type="submit"]');
  const status = contactForm.querySelector('[data-contact-status]');
  const recaptchaElement = contactForm.querySelector('[data-recaptcha-widget]');
  let isSubmitting = false;
  let recaptchaLoader;
  let recaptchaWidgetId;

  const showStatus = (message, type) => {
    status.textContent = message;
    status.dataset.type = type;
    status.classList.toggle('text-fs-red', type === 'error');
    status.classList.toggle('text-green-800', type === 'success');
    status.setAttribute('role', type === 'error' ? 'alert' : 'status');
    status.focus();
  };

  const loadRecaptcha = () => {
    if (window.grecaptcha?.enterprise) {
      return Promise.resolve();
    }

    if (!recaptchaLoader) {
      recaptchaLoader = new Promise((resolve, reject) => {
        const script = document.createElement('script');
        script.src = 'https://www.google.com/recaptcha/enterprise.js?render=explicit';
        script.async = true;
        script.addEventListener('load', resolve, { once: true });
        script.addEventListener('error', () => reject(new Error('reCAPTCHA failed to load.')), { once: true });
        document.head.append(script);
      });
    }

    return recaptchaLoader;
  };

  const renderRecaptcha = async () => {
    await loadRecaptcha();
    return new Promise((resolve, reject) => {
      window.grecaptcha.enterprise.ready(() => {
        try {
          recaptchaWidgetId = window.grecaptcha.enterprise.render(recaptchaElement, {
            sitekey: siteKey,
            action: 'CONTACT_FORM',
          });
          resolve();
        }
        catch (error) {
          reject(error);
        }
      });
    });
  };

  renderRecaptcha().catch(() => {
    showStatus('The verification checkbox could not be loaded. Please refresh the page and try again.', 'error');
    submitButton.disabled = true;
  });

  const errorMessage = (response) => {
    switch (response.status) {
      case 400:
        return 'Please check your details and try again.';
      case 403:
        return 'We could not verify this submission. Please try again.';
      case 405:
        return 'The contact service could not accept this request.';
      case 500:
        return 'The contact service is temporarily unavailable. Please try again later.';
      default:
        return `We could not send your message (error ${response.status}). Please try again.`;
    }
  };

  contactForm.addEventListener('submit', async (event) => {
    event.preventDefault();

    if (isSubmitting || !contactForm.reportValidity()) {
      return;
    }

    if (recaptchaWidgetId === undefined) {
      showStatus('The verification checkbox is still loading. Please wait a moment and try again.', 'error');
      return;
    }

    const recaptchaToken = window.grecaptcha.enterprise.getResponse(recaptchaWidgetId);
    if (!recaptchaToken) {
      showStatus('Please complete the verification checkbox before sending your message.', 'error');
      return;
    }

    isSubmitting = true;
    submitButton.disabled = true;
    submitButton.textContent = 'Sending…';
    status.textContent = '';
    status.removeAttribute('data-type');
    status.classList.remove('text-fs-red', 'text-green-800');

    try {
      const formData = new FormData(contactForm);
      const response = await fetch(endpoint, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          name: formData.get('name'),
          email: formData.get('email'),
          message: formData.get('message'),
          recaptchaToken,
        }),
      });

      if (response.status !== 202) {
        throw new Error(errorMessage(response));
      }

      const result = await response.json();
      if (result.success !== true) {
        throw new Error('The contact service returned an unexpected response. Please try again.');
      }

      contactForm.reset();
      showStatus('Thanks — your message has been sent.', 'success');
      submitButton.textContent = 'Message sent';
    }
    catch (error) {
      const message = error instanceof Error && error.message && error.message !== 'Failed to fetch'
        ? error.message
        : 'We could not send your message. Check your connection and try again.';
      showStatus(message, 'error');
      window.grecaptcha.enterprise.reset(recaptchaWidgetId);
      isSubmitting = false;
      submitButton.disabled = false;
      submitButton.textContent = 'Send message';
    }
  });
}
