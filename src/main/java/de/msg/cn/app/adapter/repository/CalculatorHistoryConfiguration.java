package de.msg.cn.app.adapter.repository;

import org.springframework.boot.autoconfigure.domain.EntityScan;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;

@Configuration
@EnableJpaRepositories(basePackages = "de.msg.cn.app.adapter.repository")
@EntityScan("de.msg.cn.app.adapter.repository.entity")
public class CalculatorHistoryConfiguration {
}
