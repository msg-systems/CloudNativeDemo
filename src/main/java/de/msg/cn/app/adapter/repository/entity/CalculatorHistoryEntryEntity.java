package de.msg.cn.app.adapter.repository.entity;

import de.msg.cn.app.domain.CalculatorOperation;
import jakarta.persistence.*;
import lombok.Data;
import org.hibernate.annotations.GenericGenerator;
import org.hibernate.annotations.Parameter;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

@Table(name = "calculator_history_entity")
@Data
@Entity
public class CalculatorHistoryEntryEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO, generator = "UUID")
    @GenericGenerator(
            name = "UUID",
            strategy = "org.hibernate.id.UUIDGenerator",
            parameters = {
                    @Parameter(
                            name = "uuid_gen_strategy_class",
                            value = "org.hibernate.id.uuid.CustomVersionOneStrategy"
                    )
            }
    )
    @Column(name = "id", nullable = false, updatable = false)
    private UUID id;

    private BigDecimal leftOperand;

    private BigDecimal rightOperand;

    @Enumerated(EnumType.STRING)
    private CalculatorOperation operation;

    private BigDecimal result;

    private Instant createdAt;
}
