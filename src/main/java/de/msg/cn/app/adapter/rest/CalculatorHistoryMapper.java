package de.msg.cn.app.adapter.rest;

import de.msg.cn.app.api.model.CalculateResponse;
import de.msg.cn.app.domain.CalculatorHistoryEntry;
import org.mapstruct.Mapper;

@Mapper
public interface CalculatorHistoryMapper {
    CalculateResponse historyEntryToResponse(CalculatorHistoryEntry historyEntry);
}
