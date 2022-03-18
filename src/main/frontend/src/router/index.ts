import { createRouter, createWebHashHistory, RouteRecordRaw } from 'vue-router';
import HomeView from '../views/HomeView.vue';
import ClassicCalculatorView from '../views/ClassicCalculatorView.vue';

const routes: Array<RouteRecordRaw> = [
  {
    path: '/',
    name: 'Home',
    component: HomeView,
  },
  {
    path: '/classicCalculator',
    name: 'Classic Calculator',
    component: ClassicCalculatorView,
  },
];

export const router = createRouter({
  history: createWebHashHistory(),
  routes,
});
