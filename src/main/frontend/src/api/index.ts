import { CalculatorApi } from "./api";
import { Configuration } from "./configuration"

export * from "./api";
export * from "./configuration";

export const apiClient = new CalculatorApi(new Configuration({ basePath: '/api' }));
