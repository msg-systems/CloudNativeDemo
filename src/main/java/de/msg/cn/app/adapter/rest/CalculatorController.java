package de.msg.cn.app.adapter.rest;

import de.msg.cn.app.api.CalculatorApi;
import de.msg.cn.app.api.model.*;
import de.msg.cn.app.application.CalculatorApplication;
import de.msg.cn.app.domain.CalculatorHistoryEntry;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Primary;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.math.BigDecimal;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.function.BiFunction;
import java.util.stream.Collectors;

@Primary
@RestController
@RequestMapping("${openapi.cloudNativeCalculator.base-path:/api}")
public class CalculatorController implements CalculatorApi {

    @Autowired
    private CalculatorApplication application;

    @Autowired
    private CalculatorHistoryMapper historyMapper;

    Map<CalculatorOperation, BiFunction<BigDecimal, BigDecimal, BigDecimal>> calcFunctions = new HashMap<>() {{
        put(CalculatorOperation.ADD, (n1, n2) -> application.add(n1, n2));
        put(CalculatorOperation.SUBTRACT, (n1, n2) -> application.subtract(n1, n2));
        put(CalculatorOperation.MULTIPLY, (n1, n2) -> application.multiply(n1, n2));
        put(CalculatorOperation.DIVIDE, (n1, n2) -> application.divide(n1, n2));
    }};

    @Override
    public ResponseEntity<CalculateResponse> calculateResult(CalculateRequest request) {
        CalculateResponse response = new CalculateResponse();
        response.setLeftOperand(request.getLeftOperand());
        response.setRightOperand(request.getRightOperand());
        response.setOperation(request.getOperation());

        response.setResult(calcFunctions.get(request.getOperation()).apply(request.getLeftOperand(), request.getRightOperand()));
        return new ResponseEntity<>(response, HttpStatus.OK);
    }

    @Override
    public ResponseEntity<List<CalculateResponse>> calculatorHistory() {
        List<CalculatorHistoryEntry> history = application.getCalculatorHistory();

        List<CalculateResponse> responseList = history.stream()
                .map(entry -> historyMapper.historyEntryToResponse(entry))
                .collect(Collectors.toList());

        return new ResponseEntity<>(responseList, HttpStatus.OK);
    }

    @Override
    public ResponseEntity<Void> deleteHistory() {
        application.deleteCalculatorHistory();
        return new ResponseEntity<>(HttpStatus.NO_CONTENT);
    }
}
