package com.example.japanese_learning.features.sample_sentences.service;

import com.example.japanese_learning.dto.response.SampleSentenceGroupResponse;
import com.example.japanese_learning.dto.response.SentenceItemResponse;
import com.example.japanese_learning.dto.response.SentencePartResponse;
import com.example.japanese_learning.entity.account.SampleSentenceGroup;
import com.example.japanese_learning.entity.account.SentenceItem;
import com.example.japanese_learning.entity.account.SentencePart;
import com.example.japanese_learning.enums.GroupType;
import com.example.japanese_learning.features.sample_sentences.repository.SampleSentenceGroupRepository;
import com.example.japanese_learning.features.sample_sentences.repository.SentenceItemRepository;
import com.example.japanese_learning.features.sample_sentences.repository.SentencePartRepository;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.annotation.PostConstruct;
import lombok.RequiredArgsConstructor;
import org.springframework.core.io.ClassPathResource;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;

@Service
@RequiredArgsConstructor
public class SampleSentenceService {

    private final SampleSentenceGroupRepository groupRepository;
    private final SentencePartRepository partRepository;
    private final SentenceItemRepository itemRepository;

    @Transactional(readOnly = true)
    public List<SampleSentenceGroupResponse> getGroups(String typeStr) {
        GroupType type = GroupType.valueOf(typeStr.toUpperCase());
        return groupRepository.findByGroupType(type).stream()
                .map(this::mapToGroupResponse)
                .toList();
    }

    @Transactional(readOnly = true)
    public List<SentencePartResponse> getParts(Long groupId) {
        return partRepository.findByGroup_Id(groupId).stream()
                .map(this::mapToPartResponse)
                .toList();
    }

    @Transactional(readOnly = true)
    public List<SentenceItemResponse> getSentences(Long partId) {
        return itemRepository.findByPart_Id(partId).stream()
                .map(this::mapToSentenceResponse)
                .toList();
    }

    private SampleSentenceGroupResponse mapToGroupResponse(SampleSentenceGroup g) {
        return SampleSentenceGroupResponse.builder()
                .id(String.valueOf(g.getId()))
                .type(g.getGroupType())
                .name(g.getGroupName())
                .jlptLevel(g.getJlptLevel())
                .build();
    }

    private SentencePartResponse mapToPartResponse(SentencePart p) {
        return SentencePartResponse.builder()
                .id(String.valueOf(p.getId()))
                .groupId(String.valueOf(p.getGroup().getId()))
                .title(p.getPartTitle())
                .description(p.getDescription())
                .icon(p.getIcon())
                .build();
    }

    private SentenceItemResponse mapToSentenceResponse(SentenceItem s) {
        List<String> words = new ArrayList<>();
        if (s.getScrambledRawText() != null && !s.getScrambledRawText().isEmpty()) {
            words = Arrays.asList(s.getScrambledRawText().split("/"));
        }
        return SentenceItemResponse.builder()
                .id(String.valueOf(s.getId()))
                .partId(String.valueOf(s.getPart().getId()))
                .kanji(s.getSentenceKanji())
                .hira(s.getSentenceHiragana())
                .viet(s.getTranslationPrompt())
                .words(words)
                .explanation(s.getExplanation())
                .audioUrl(s.getAudioUrl())
                .build();
    }

    @PostConstruct
    @Transactional
    public void seedDatabase() {
        try {
            groupRepository.alterGroupTypeColumn();
        } catch (Exception e) {
            System.err.println("Could not alter group_type column: " + e.getMessage());
        }
        if (groupRepository.count() == 0) {
            try {
                ObjectMapper mapper = new ObjectMapper();
                ClassPathResource resource = new ClassPathResource("sentences.json");
                JsonNode root = mapper.readTree(resource.getInputStream());

                // Seed Groups
                JsonNode groupsNode = root.get("sample_sentence_groups");
                Map<String, SampleSentenceGroup> groupMap = new HashMap<>();
                if (groupsNode != null && groupsNode.isArray()) {
                    for (JsonNode gNode : groupsNode) {
                        String jsonId = gNode.get("id").asText();
                        String typeStr = gNode.get("type").asText();
                        String name = gNode.get("name").asText();
                        String jlpt = gNode.has("jlptLevel") ? gNode.get("jlptLevel").asText() : "ALL";

                        SampleSentenceGroup group = new SampleSentenceGroup();
                        group.setGroupType(GroupType.valueOf(typeStr));
                        group.setGroupName(name);
                        group.setJlptLevel(jlpt);
                        group = groupRepository.save(group);
                        groupMap.put(jsonId, group);
                    }
                }

                // Seed Parts
                JsonNode partsNode = root.get("sentence_parts");
                Map<String, SentencePart> partMap = new HashMap<>();
                if (partsNode != null && partsNode.isArray()) {
                    for (JsonNode pNode : partsNode) {
                        String jsonId = pNode.get("id").asText();
                        String groupId = pNode.get("groupId").asText();
                        String title = pNode.get("title").asText();
                        String description = pNode.has("description") ? pNode.get("description").asText() : "";
                        String icon = pNode.has("icon") ? pNode.get("icon").asText() : "";

                        SampleSentenceGroup group = groupMap.get(groupId);
                        if (group != null) {
                            SentencePart part = new SentencePart();
                            part.setGroup(group);
                            part.setPartTitle(title);
                            part.setDescription(description);
                            part.setIcon(icon);
                            part = partRepository.save(part);
                            partMap.put(jsonId, part);
                        }
                    }
                }

                // Seed Sentences
                JsonNode sentencesNode = root.get("sentences");
                if (sentencesNode != null && sentencesNode.isArray()) {
                    int num = 1;
                    for (JsonNode sNode : sentencesNode) {
                        String partId = sNode.get("partId").asText();
                        String kanji = sNode.get("kanji").asText();
                        String hira = sNode.get("hira").asText();
                        String viet = sNode.get("viet").asText();
                        String explanation = sNode.has("explanation") ? sNode.get("explanation").asText() : "";

                        List<String> wordsList = new ArrayList<>();
                        if (sNode.has("words") && sNode.get("words").isArray()) {
                            for (JsonNode wNode : sNode.get("words")) {
                                wordsList.add(wNode.asText());
                            }
                        }
                        String scrambledRaw = String.join("/", wordsList);

                        SentencePart part = partMap.get(partId);
                        if (part != null) {
                            SentenceItem item = new SentenceItem();
                            item.setPart(part);
                            item.setSentenceNumber(num++);
                            item.setSentenceKanji(kanji);
                            item.setSentenceHiragana(hira);
                            item.setTranslationPrompt(viet);
                            item.setScrambledRawText(scrambledRaw);
                            item.setExplanation(explanation);
                            item.setAudioUrl(""); // default empty string
                            itemRepository.save(item);
                        }
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }
}
