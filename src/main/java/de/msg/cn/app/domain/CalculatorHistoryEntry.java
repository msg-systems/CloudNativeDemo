package de.msg.cn.app.domain;

import lombok.Builder;
import lombok.Data;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

@Data
@Builder
public class CalculatorHistoryEntry {
    private UUID id;
    private BigDecimal leftOperand;
    private BigDecimal rightOperand;
    private CalculatorOperation operation;
    private BigDecimal result;
    private Instant createdAt;
}
