package de.msg.cn.app.application;

import de.msg.cn.app.domain.CalculatorHistoryEntry;
import de.msg.cn.app.domain.CalculatorHistoryRepository;
import de.msg.cn.app.domain.CalculatorOperation;
import de.msg.cn.app.domain.DivideByZeroException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.ComponentScan;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.List;

@SpringBootApplication()
@ComponentScan(basePackages = {"de.msg.cn.app"})
public class CalculatorApplicationImpl implements CalculatorApplication {

	public static void main(String[] args) {
		SpringApplication.run(CalculatorApplicationImpl.class, args);
	}

	@Autowired
	private CalculatorHistoryRepository calculatorHistory;

	@Override
	public BigDecimal add(BigDecimal a, BigDecimal b) {

		BigDecimal result = a.add(b);

		calculatorHistory.createEntry(CalculatorHistoryEntry.builder()
				.leftOperand(a)
				.rightOperand(b)
				.operation(CalculatorOperation.ADD)
				.result(result)
				.build()
		);

		return result;
	}

	@Override
	public BigDecimal subtract(BigDecimal a, BigDecimal b) {
		BigDecimal result = a.subtract(b);

		calculatorHistory.createEntry(CalculatorHistoryEntry.builder()
				.leftOperand(a)
				.rightOperand(b)
				.operation(CalculatorOperation.SUBTRACT)
				.result(result)
				.build()
		);

		return result;
	}

	@Override
	public BigDecimal multiply(BigDecimal a, BigDecimal b) {
		BigDecimal result = a.multiply(b);

		calculatorHistory.createEntry(CalculatorHistoryEntry.builder()
				.leftOperand(a)
				.rightOperand(b)
				.operation(CalculatorOperation.MULTIPLY)
				.result(result)
				.build()
		);

		return result;
	}

	@Override
	public BigDecimal divide(BigDecimal a, BigDecimal b) {

		if (b.equals(BigDecimal.ZERO)) {
			throw new DivideByZeroException("Division by 0 is not allowed.");
		}

		BigDecimal result = a.divide(b, 5, RoundingMode.HALF_UP);

		calculatorHistory.createEntry(CalculatorHistoryEntry.builder()
				.leftOperand(a)
				.rightOperand(b)
				.operation(CalculatorOperation.DIVIDE)
				.result(result)
				.build()
		);

		return result;
	}

	@Override
	public List<CalculatorHistoryEntry> getCalculatorHistory() {
		return calculatorHistory.findAll();
	}

	@Override
	public void deleteCalculatorHistory() {
		calculatorHistory.deleteAll();
	}
}
