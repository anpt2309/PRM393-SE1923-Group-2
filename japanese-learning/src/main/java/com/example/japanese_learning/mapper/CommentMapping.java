package com.example.japanese_learning.mapper;

import com.example.japanese_learning.dto.response.CommentResponse;
import com.example.japanese_learning.entity.exam.Comment;
import org.mapstruct.Mapper;
import org.mapstruct.NullValuePropertyMappingStrategy;

@Mapper(componentModel = "spring", nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE)
public interface CommentMapping {

    CommentResponse toCommentResponse(Comment comment);
}
