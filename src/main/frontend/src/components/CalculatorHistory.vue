<template>
  <Card>
    <template #subtitle>
      <div class="flex justify-between">
        <span>
          Previous calculations
        </span>
        <span class="buttons">
          <Button
            title="Reload"
            icon="pi pi-refresh"
            class="p-button-outlined p-button-secondary p-button-rounded mr-4"
            @click="load"
          />
          <Button
            title="Clear history"
            icon="pi pi-trash"
            class="p-button-outlined p-button-secondary p-button-rounded"
            data-testid="clearHistory"
            @click="clearHistory"
          />
        </span>
      </div>
    </template>
    <template #content>
      <DataTable
        :value="calculations"
        :scrollable="true"
        scroll-height="flex"
        striped-rows
        :loading="isLoading"
        responsive-layout="scroll"
        data-testid="calculator-history-table"
      >
        <Column
          field="leftOperand"
          header="Left Operand"
        />
        <Column
          field="operation"
          header="Operation"
        />
        <Column
          field="rightOperand"
          header="Right Operand"
        />
        <Column
          field="result"
          header="Result"
        />
      </DataTable>
    </template>
  </Card>
</template>

<script setup lang="ts">
import { onMounted } from 'vue';
import Button from 'primevue/button';
import Card from 'primevue/card';
import Column from 'primevue/column';
import DataTable from 'primevue/datatable';
import { useToast } from 'primevue/usetoast';
import { apiClient, CalculateResponse } from '@/api';
import { useRemoteApi } from '@/composables/useRemoteApi';

const { responseData: calculations, isLoading, callApi } = useRemoteApi<CalculateResponse[]>(useToast());
const load = () => {
  callApi(apiClient.calculatorHistory());
};

onMounted(load);

const { callApi: callDeleteHistory } = useRemoteApi<void>(useToast());
const clearHistory = () => {
  callDeleteHistory(apiClient.deleteHistory()).then(load);
};

export interface CalculatorHistoryInterface {
  load: () => Promise<void>
}
defineExpose({ load } as CalculatorHistoryInterface);
</script>

<style scoped lang="scss">
.buttons {
  margin-top: -0.25rem;

  button {
    width: 2rem !important;
    height: 2rem !important;
  }
}
</style>
