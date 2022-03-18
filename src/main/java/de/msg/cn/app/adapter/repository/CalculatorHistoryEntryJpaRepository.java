package de.msg.cn.app.adapter.repository;

import de.msg.cn.app.adapter.repository.entity.CalculatorHistoryEntryEntity;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface CalculatorHistoryEntryJpaRepository extends JpaRepository<CalculatorHistoryEntryEntity, UUID> {
    List<CalculatorHistoryEntryEntity> findByOrderByCreatedAtDesc(Pageable firstPage);
}