import { Ref, ref } from 'vue';
import { isAxiosError, AxiosResponse } from 'axios';

export interface UseRemoteApiReturn<T> {
  responseData: Ref<T | undefined>
  isLoading: Ref<boolean>
  callApi: (promise: Promise<AxiosResponse<T>>) => Promise<T | undefined>
}

interface ToastService {
  add(args:{ severity?: string, summary?: string, detail?: string, life?: number, closable?: boolean, group?: string }): void;
}

export function useRemoteApi<T>(toastService: ToastService): UseRemoteApiReturn<T> {
  const responseData = ref<T>();
  const isLoading = ref(false);

  const callApi = async (promise: Promise<AxiosResponse<T>>) => {
    isLoading.value = true;
    try {
      const response = await promise;
      if (response) {
        responseData.value = response.data;
        return response.data;
      }
    } catch (e: unknown) {
      let detail;
      if (isAxiosError(e)) {
        detail = e.response?.data?.message || 'An unexpected error occurred';
      } else {
        detail = 'An unexpected error occurred';
      }
      toastService.add({ severity: 'error', summary: 'Error', detail });
    } finally {
      isLoading.value = false;
    }
    return undefined;
  };

  return {
    responseData,
    isLoading,
    callApi,
  };
}
