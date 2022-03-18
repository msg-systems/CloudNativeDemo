import { Component } from 'vue';
import { fireEvent, render as _render, RenderResult } from '@testing-library/vue';
import PrimeVue from 'primevue/config';
import ToastService from 'primevue/toastservice';
import userEvent from '@testing-library/user-event';
import { typeOptions } from '@testing-library/user-event/dist/types/utility/type';

export function render(testComponent: Component): RenderResult {
  return _render(testComponent, { global: { plugins: [PrimeVue, ToastService] } });
}

export async function clearAndType(element: Element, text: string, options?: typeOptions & { delay?: 0; }): Promise<void> {
  userEvent.clear(element);
  userEvent.type(element, text, options);
  await fireEvent.blur(element);
}
