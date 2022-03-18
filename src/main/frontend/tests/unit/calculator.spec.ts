import { waitFor, waitForElementToBeRemoved } from '@testing-library/vue';
import '@testing-library/jest-dom';
import { within } from '@testing-library/dom';
import { AxiosResponse } from 'axios';
import { mocked } from 'jest-mock';
import CalculatorClassic from '@/components/CalculatorClassic.vue';
import {
  CalculateRequest, CalculateResponse, apiClient, CalculatorOperation,
} from '@/api';
import { clearAndType, render } from './util';

// Mock API
jest.mock('@/api');
const mockedClient = mocked(apiClient, { shallow: true });
const mockResolvedValueOnce = (data: CalculateResponse) => mockedClient.calculateResult.mockResolvedValueOnce({ data } as AxiosResponse);
const mockRejectedValueOnce = (data?: CalculateResponse) => mockedClient.calculateResult.mockRejectedValueOnce({ data } as AxiosResponse);

// Mock PrimeVue's Toast-Service
const mockAddToast = jest.fn();
jest.mock(
  'primevue/usetoast',
  () => ({ useToast: () => ({ add: mockAddToast }) }),
);

// Constants for querying elements
const DIV_RESULT = 'result';

describe('CalculatorClassic.vue', () => {
  afterEach(() => {
    jest.resetAllMocks();
  });

  it('should have expected initial values', async () => {
    const { getByText, getByLabelText, getByTestId } = render(CalculatorClassic);

    expect(getByText('New calculation')).toBeInTheDocument();
    expect(getByTestId(DIV_RESULT)).toHaveValue('');
    expect(getByLabelText('=')).toBeInTheDocument();
    expect(getByLabelText('=')).toBeDisabled();
  });

  it.each([
    ['+', CalculatorOperation.Add],
    ['-', CalculatorOperation.Subtract],
    ['*', CalculatorOperation.Multiply],
    ['/', CalculatorOperation.Divide],
  ])('should offer operation \'%s\' and use it correctly in API calls', async (operationBtnText: string, expectedApiOperation: CalculatorOperation) => {
    const { getByLabelText, getByTestId } = render(CalculatorClassic);

    const returnedResult = 3;
    const expectedRequest : CalculateRequest = { leftOperand: 3, rightOperand: 3, operation: expectedApiOperation };
    mockResolvedValueOnce({ ...expectedRequest, result: returnedResult }); // yes 3 is not the correct result, doesn't matter for the UI test

    getByLabelText('3').click();
    getByLabelText(operationBtnText).click();
    getByLabelText('3').click();
    await waitFor(() => expect(getByLabelText('=')).not.toBeDisabled());
    getByLabelText('=').click();
    await waitFor(() => expect(mockedClient.calculateResult).toHaveBeenLastCalledWith(expectedRequest));
    await waitFor(() => expect(getByTestId(DIV_RESULT)).toHaveValue('3 ' + operationBtnText + ' 3 = ' + returnedResult));
  });

  it('should continue calculation with previous result', async () => {
    const { getByTestId, getByLabelText } = render(CalculatorClassic);

    const expectedRequest : CalculateRequest = { leftOperand: 3, rightOperand: 2, operation: CalculatorOperation.Subtract };
    mockResolvedValueOnce({ ...expectedRequest, result: 1 });
    getByLabelText('3').click();
    getByLabelText('-').click();
    getByLabelText('2').click();
    await waitFor(() => expect(getByLabelText('=')).not.toBeDisabled());
    getByLabelText('=').click();
    await waitFor(() => expect(mockedClient.calculateResult).toHaveBeenLastCalledWith(expectedRequest));
    await waitFor(() => expect(getByTestId(DIV_RESULT)).toHaveValue('3 - 2 = 1'));

    const expectedRequest2 : CalculateRequest = { leftOperand: 1, rightOperand: 5, operation: CalculatorOperation.Add };
    mockResolvedValueOnce({ ...expectedRequest, result: 6 });
    getByLabelText('+').click();
    getByLabelText('5').click();
    await waitFor(() => expect(getByLabelText('=')).not.toBeDisabled());
    getByLabelText('=').click();
    await waitFor(() => expect(mockedClient.calculateResult).toHaveBeenLastCalledWith(expectedRequest2));
    await waitFor(() => expect(getByTestId(DIV_RESULT)).toHaveValue('1 + 5 = 6'));
  });

  it('should discard result when number is input after =', async () => {
    const { getByTestId, getByLabelText } = render(CalculatorClassic);
    const expectedRequest : CalculateRequest = { leftOperand: 1, rightOperand: 1, operation: CalculatorOperation.Add };
    mockResolvedValueOnce({ ...expectedRequest, result: 2 });

    getByLabelText('1').click();
    getByLabelText('+').click();
    getByLabelText('1').click();
    await waitFor(() => expect(getByLabelText('=')).not.toBeDisabled());
    getByLabelText('=').click();
    await waitFor(() => expect(mockedClient.calculateResult).toHaveBeenLastCalledWith(expectedRequest));
    await waitFor(() => expect(getByTestId(DIV_RESULT)).toHaveValue('1 + 1 = 2'));
    getByLabelText('5').click();
    await waitFor(() => expect(getByTestId(DIV_RESULT)).toHaveValue('5'));
  });

  it('should clear input on C', async () => {
    const { getByTestId, getByLabelText } = render(CalculatorClassic);

    getByLabelText('1').click();
    getByLabelText('+').click();
    await waitFor(() => expect(getByTestId(DIV_RESULT)).toHaveValue('1 +'));
    getByLabelText('C').click();
    await waitFor(() => expect(getByTestId(DIV_RESULT)).toHaveValue(''));
  });

  it('should add a toast on API error', async () => {
    const { getByLabelText } = render(CalculatorClassic);
    mockRejectedValueOnce();

    getByLabelText('1').click();
    getByLabelText('+').click();
    getByLabelText('1').click();
    await waitFor(() => expect(getByLabelText('=')).not.toBeDisabled());
    getByLabelText('=').click();

    await waitFor(() => expect(mockAddToast).toHaveBeenCalledTimes(1));
  });

  it('should emit event after calculation', async () => {
    const { getByLabelText, getByTestId, emitted } = render(CalculatorClassic);
    const expectedRequest : CalculateRequest = { leftOperand: 1, rightOperand: 1, operation: CalculatorOperation.Add };
    const actualResponse : CalculateResponse = { ...expectedRequest, result: 2 };
    mockResolvedValueOnce(actualResponse);

    getByLabelText('1').click();
    getByLabelText('+').click();
    getByLabelText('1').click();
    await waitFor(() => expect(getByLabelText('=')).not.toBeDisabled());
    getByLabelText('=').click();

    await waitFor(() => expect(mockedClient.calculateResult).toHaveBeenLastCalledWith(expectedRequest));
    await waitFor(() => expect(getByTestId(DIV_RESULT)).toHaveValue('1 + 1 = 2'));

    expect(emitted().calculated.length).toBe(1);
    expect(emitted().calculated[0]).toEqual([actualResponse]);
  });
});
