import '@testing-library/jest-dom';
import { AxiosResponse } from 'axios';
import { mocked } from 'jest-mock';
import { waitForElementToBeRemoved } from '@testing-library/vue';
import CalculatorHistory from '@/components/CalculatorHistory.vue';
import { apiClient, CalculateResponse, CalculatorOperation } from '@/api';
import { render } from './util';

// Mock API
jest.mock('@/api');
const mockedClient = mocked(apiClient);
const mockResolvedValueOnce = (data: Array<CalculateResponse>) => mockedClient.calculatorHistory.mockResolvedValueOnce({ data } as AxiosResponse);

// Mock PrimeVue's Toast-Service
const mockAddToast = jest.fn();
jest.mock(
  'primevue/usetoast',
  () => ({ useToast: () => ({ add: mockAddToast }) }),
);

describe('CalculatorHistory.vue', () => {
  afterEach(() => {
    jest.resetAllMocks();
  });

  it('should load and display the history of calculations', async () => {
    mockResolvedValueOnce([{
      leftOperand: 1, rightOperand: 1, operation: CalculatorOperation.Add, result: 2,
    }]);
    const { container } = render(CalculatorHistory);

    await waitForElementToBeRemoved(container.querySelector('.p-datatable-emptymessage'));

    expect(Array.from(container.getElementsByTagName('th')).map((el: HTMLTableHeaderCellElement) => el.textContent))
      .toStrictEqual(['Left Operand', 'Operation', 'Right Operand', 'Result']);
    expect(Array.from(container.getElementsByTagName('td')).map((el: HTMLTableDataCellElement) => el.textContent))
      .toStrictEqual(['1', 'ADD', '1', '2']);
  });
});
