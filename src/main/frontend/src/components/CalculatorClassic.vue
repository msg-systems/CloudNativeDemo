<template>
  <Card>
    <template #subtitle>
      New calculation
    </template>
    <template
      #content
    >
      <div
        class="flex gap-4 mb-4"
      >
        <InputText
          :model-value="calculationString"
          type="text"
          class="w-full text-right text-black"
          disabled
          data-testid="result"
        />
        <Button
          label="C"
          class="p-button-secondary p-button-outlined"
          @click="clear"
        />
      </div>
      <div
        class="flex gap-4"
      >
        <div
          class="grid grid-cols-3 gap-4 flex-1"
        >
          <template
            v-for="(number, i) in numbers"
            :key="i"
          >
            <Button
              v-if="number !== null"
              :label="number?.toString()"
              class="p-button-outlined"
              @click="onNumberClicked(number)"
            />
            <span v-else />
          </template>
        </div>

        <div class="flex flex-col gap-4">
          <template
            v-for="op in operationOptions"
            :key="op.label"
          >
            <Button
              :label="op.label"
              :disabled="operation !== undefined && result === undefined"
              class="p-button-secondary p-button-outlined"
              @click="onOperationClicked(op)"
            />
          </template>
        </div>

        <Button
          label="="
          :disabled="rightOperand === undefined || result !== undefined || isLoading"
          class="p-button-secondary p-button-outlined"
          @click="calculate"
        />
      </div>
    </template>
  </Card>
</template>

<script setup lang="ts">
import {
  computed, ref,
} from 'vue';
import Button from 'primevue/button';
import Card from 'primevue/card';
import InputText from 'primevue/inputtext';
import { useToast } from 'primevue/usetoast';
import {
  CalculateRequest, apiClient, CalculatorOperation, CalculateResponse,
} from '@/api';
import { useRemoteApi } from '@/composables/useRemoteApi';

const emits = defineEmits(['calculated']);

interface OperationOption {
  label: string,
  type: CalculatorOperation,
}
const operationOptions = ref<OperationOption[]>([
  { label: '+', type: CalculatorOperation.Add },
  { label: '-', type: CalculatorOperation.Subtract },
  { label: '*', type: CalculatorOperation.Multiply },
  { label: '/', type: CalculatorOperation.Divide }]);

const numbers = [7, 8, 9, 4, 5, 6, 1, 2, 3, null, 0];

const leftOperand = ref<number>();
const rightOperand = ref<number>();
const operation = ref<OperationOption>();
const result = ref<number>();

const clear = () => {
  leftOperand.value = undefined;
  rightOperand.value = undefined;
  operation.value = undefined;
  result.value = undefined;
};

const onNumberClicked = (number: number) => {
  if (result.value !== undefined) {
    clear();
  }
  const currentOperand = operation.value === undefined ? leftOperand : rightOperand;
  if (currentOperand.value === undefined) {
    currentOperand.value = number;
  } else {
    currentOperand.value = (currentOperand.value * 10) + number;
  }
};

const onOperationClicked = (selectedOperation: OperationOption) => {
  if (leftOperand.value === undefined) {
    leftOperand.value = 0;
  }
  operation.value = selectedOperation;
  if (result.value !== undefined) {
    leftOperand.value = result.value;
    rightOperand.value = undefined;
    result.value = undefined;
  }
};

const { isLoading, callApi } = useRemoteApi<CalculateResponse>(useToast());
const calculate = async () => {
  if (leftOperand.value === undefined || rightOperand.value === undefined || operation.value === undefined) {
    return;
  }
  const request: CalculateRequest = {
    leftOperand: leftOperand.value,
    rightOperand: rightOperand.value,
    operation: operation.value.type,
  };
  const responseData = await callApi(apiClient.calculateResult(request));
  if (responseData) {
    result.value = responseData.result;
    emits('calculated', responseData);
  }
};

const calculationString = computed(() => {
  let value = '';
  if (leftOperand.value !== undefined) {
    value += leftOperand.value;
  }
  if (operation.value !== undefined) {
    value += ` ${operation.value.label}`;
  }
  if (rightOperand.value !== undefined) {
    value += ` ${rightOperand.value}`;
  }
  if (result.value !== undefined) {
    value += ` = ${result.value}`;
  }
  return value;
});
</script>
