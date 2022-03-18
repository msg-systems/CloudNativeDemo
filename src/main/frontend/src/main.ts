import { createApp } from 'vue';
import PrimeVue from 'primevue/config';
import ToastService from 'primevue/toastservice';
import App from './App.vue';
import { router } from './router';
import 'primevue/resources/themes/tailwind-light/theme.css';
import 'primevue/resources/primevue.min.css';
import 'primeicons/primeicons.css';
import './assets/styles.css';

createApp(App)
  .use(router)
  .use(PrimeVue)
  .use(ToastService)
  .mount('#app');
