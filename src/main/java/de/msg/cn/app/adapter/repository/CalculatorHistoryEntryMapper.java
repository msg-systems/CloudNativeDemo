package de.msg.cn.app.adapter.repository;

import de.msg.cn.app.adapter.repository.entity.CalculatorHistoryEntryEntity;
import de.msg.cn.app.domain.CalculatorHistoryEntry;
import org.mapstruct.Mapper;
import org.springframework.stereotype.Component;

import java.util.List;

@Mapper
@Component
public abstract class CalculatorHistoryEntryMapper {

    abstract CalculatorHistoryEntryEntity fromDomain(CalculatorHistoryEntry calculatorHistoryEntry);

    abstract List<CalculatorHistoryEntry> toDomain(List<CalculatorHistoryEntryEntity> calculatorHistoryEntryEntities);
}
