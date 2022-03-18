<template>
  <div class="p-component flex flex-col bg-gray-100 min-h-screen">
    <app-menu />
    <div class="p-5 flex flex-col flex-auto">
      <router-view />
    </div>
  </div>
  <Toast position="bottom-right" />
</template>

<script setup lang="ts">
import Toast from 'primevue/toast';
import AppMenu from '@/components/AppMenu.vue';
</script>

<style lang="scss">
body {
  padding: 0;
  margin: 0;
}

h1 {
  margin-top: 0;
  color: var(--surface-700);
}
</style>
