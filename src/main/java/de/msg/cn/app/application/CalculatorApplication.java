package de.msg.cn.app.application;

import de.msg.cn.app.domain.CalculatorHistoryEntry;

import java.math.BigDecimal;
import java.util.List;

public interface CalculatorApplication {
    BigDecimal add(BigDecimal a, BigDecimal b);
    BigDecimal subtract(BigDecimal a, BigDecimal b);
    BigDecimal multiply(BigDecimal a, BigDecimal b);
    BigDecimal divide(BigDecimal a, BigDecimal b);
    List<CalculatorHistoryEntry> getCalculatorHistory();
    void deleteCalculatorHistory();
}
