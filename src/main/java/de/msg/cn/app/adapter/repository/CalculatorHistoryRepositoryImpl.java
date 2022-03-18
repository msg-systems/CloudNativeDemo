package de.msg.cn.app.adapter.repository;

import de.msg.cn.app.adapter.repository.entity.CalculatorHistoryEntryEntity;
import de.msg.cn.app.domain.CalculatorConfig;
import de.msg.cn.app.domain.CalculatorHistoryEntry;
import de.msg.cn.app.domain.CalculatorHistoryRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Component;

import java.time.Instant;
import java.util.List;

@Component
@RequiredArgsConstructor
public class CalculatorHistoryRepositoryImpl implements CalculatorHistoryRepository {

    private final CalculatorHistoryEntryJpaRepository repository;
    private final CalculatorHistoryEntryMapper mapper;
    private final CalculatorConfig config;

    @Override
    public void createEntry(CalculatorHistoryEntry entry) {
        entry.setCreatedAt(Instant.now());
        repository.save(mapper.fromDomain(entry));
    }

    @Override
    public List<CalculatorHistoryEntry> findAll() {
        Pageable firstPage = PageRequest.of(0, config.getMaxResultsHistory());
        List<CalculatorHistoryEntryEntity> entityList = repository.findByOrderByCreatedAtDesc(firstPage);
        return mapper.toDomain(entityList);
    }

    @Override
    public void deleteAll() {
        repository.deleteAll();
    }
}
