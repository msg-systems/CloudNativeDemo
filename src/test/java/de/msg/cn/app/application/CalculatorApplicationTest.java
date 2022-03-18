package de.msg.cn.app.application;

import de.msg.cn.app.domain.CalculatorHistoryRepository;
import de.msg.cn.app.domain.DivideByZeroException;
import org.assertj.core.api.Assertions;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;

@ExtendWith(MockitoExtension.class)
public class CalculatorApplicationTest {

    @Mock
    private CalculatorHistoryRepository repository;

    @InjectMocks
    private CalculatorApplicationImpl application;


    @Test
    public void shouldAddOperands() {
        Assertions.assertThat(application.add(BigDecimal.valueOf(2), BigDecimal.valueOf(3))).isEqualTo(BigDecimal.valueOf(5));
    }

    @Test
    public void shouldSubtractOperands() {
        Assertions.assertThat(application.subtract(BigDecimal.valueOf(2), BigDecimal.valueOf(3))).isEqualTo(BigDecimal.valueOf(-1));
    }

    @Test
    public void shouldMultiplyOperands() {
        Assertions.assertThat(application.multiply(BigDecimal.valueOf(2), BigDecimal.valueOf(3))).isEqualTo(BigDecimal.valueOf(6));
    }

    @Test
    public void shouldDivideOperands() {
        Assertions.assertThat(application.divide(BigDecimal.valueOf(2), BigDecimal.valueOf(3)))
                .isCloseTo(BigDecimal.valueOf(2.0/3.0), Assertions.byLessThan(BigDecimal.valueOf(0.0001d)));
    }

    @Test
    public void shouldNotDivideByZero() {
        Assertions.assertThatThrownBy(() -> application.divide(BigDecimal.valueOf(2), BigDecimal.valueOf(0)))
                .isInstanceOf(DivideByZeroException.class);
    }

}
