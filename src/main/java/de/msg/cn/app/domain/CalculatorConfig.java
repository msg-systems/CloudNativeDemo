package de.msg.cn.app.domain;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

@Component
@Data
@ConfigurationProperties(prefix = "calculator")
public class CalculatorConfig {
    private int maxResultsHistory;
}
