package de.msg.cn.app.domain;

import java.util.List;

public interface CalculatorHistoryRepository {
    void createEntry(CalculatorHistoryEntry entry);
    List<CalculatorHistoryEntry> findAll();
    void deleteAll();
}
