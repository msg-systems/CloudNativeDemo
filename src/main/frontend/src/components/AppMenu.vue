<template>
  <div class="w-full px-5 py-3 bg-indigo-600 shadow-lg ">
    <Menubar
      :model="items"
      class="p-0 border-none"
    >
      <template #start>
        <a href="/#">
          <GlobeIcon class="mr-5 text-white" />
        </a>
      </template>
      <template #end>
        <span class="text-gray-100 text-sm">
          Version: {{ version }}
        </span>
      </template>
    </Menubar>
  </div>
</template>

<script setup lang="ts">
import Menubar from 'primevue/menubar';
import GlobeIcon from '@/components/icons/GlobeIcon.vue';

const items = [
  { label: 'Home', icon: 'pi pi-fw pi-home', to: '/' },
  { label: 'Classic Calculator', icon: 'pi pi-fw pi-cog', to: '/classicCalculator' },
];

const version = process.env.VUE_APP_VERSION || 'undefined';
</script>

<style scoped lang="scss">
::v-deep(.p-menubar) {
  background: initial;

  .p-menuitem-link {
    padding-left: 32px !important;
    padding-right: 32px !important;

    &:hover {
      background: #4338CA !important;
    }
  }
  .p-menuitem-icon, .p-menuitem-text {
    color: var(--surface-300) !important;
  }
  .p-menuitem:hover, .p-menuitem-link.router-link-active {
    .p-menuitem-icon, .p-menuitem-text {
      color: var(--surface-0) !important;
    }
  }
}
</style>
