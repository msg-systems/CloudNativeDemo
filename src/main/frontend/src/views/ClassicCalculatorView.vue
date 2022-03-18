<template>
  <h1>
    Classic Calculator
  </h1>
  <div class="grid grid-cols-1 lg:grid-cols-2 gap-8">
    <ClassicCalculator @calculated="onCalculated" />
    <CalculatorHistory ref="calculatorHistory" />
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';
import ClassicCalculator from '@/components/CalculatorClassic.vue';
import CalculatorHistory, { CalculatorHistoryInterface } from '@/components/CalculatorHistory.vue';

const calculatorHistory = ref<CalculatorHistoryInterface | null>(null);

const onCalculated = () => {
  if (calculatorHistory.value) {
    calculatorHistory.value.load();
  }
};
</script>
