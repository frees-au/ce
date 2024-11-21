export const plugins = [require(
  '@tailwindcss/typography',
  '@tailwindcss/form',
)];
export const content = [
  'templates/**/*.twig',
  '../../../../config/sync/editor.editor.safe_html.yml',
  'src/css/ckeditor5.css',
  'src/ckeditor5_templates.json',
];
export const variants = {
  extend: {},
};
export const theme = {
  fontFamily: {
    'mono': ['Cutive Mono', 'Sans-Serif'],
    'sans': ['Open Sans', 'Sans-Serif'],
  },
  screens: {
    sm: '640px',
    md: '768px',
    lg: '1440px',
    xl: '1920px'
  },
  container: {
    center: true,
    padding: {
      DEFAULT: '30px',
      md: '40px',
      lg: '112px',
      xl: '250px',
    }
  },
  extend: {
    colors: {
      'fs-red': '#851520',
      'fs-red-tint': '#B11F24',
      'fs-dark-grey': '#BFBFBF',
      'fs-light-grey': '#F5F5F5',
    },
    boxShadow: {
      popped: '0 35px 60px -15px rgba(0, 0, 0, 0.3)',
    },
    keyframes: {
      slideIn: {
        "0%": { opacity: 0, transform: "translateY(100%)" },
        "100%": { opacity: 1, transform: "translateY(0)" },
      },
    },
    animation: {
      slideIn: "slideIn 1s ease-in-out forwards var(--delay, 0)",
    },
    typography: (theme) => ({
      DEFAULT: {
        css: {
          a: {
            textDecoration: `none`,
            '&:hover': {
              textDecoration: `underline`,
            },
          },
          pre: {
            'max-width': '90vw',
            'overflow-x': 'scroll',
          },
          code: {
            color: 'var(--tw-prose-code)',
            'color': '#a71f23',
            'background-color': '#eee',
            'padding': '.2em',
            fontWeight: '600',
          },
          'code::before': {
            content: '',
          },
          'code::after': {
            content: '',
          },
        },
      },
    }),
  },
};
