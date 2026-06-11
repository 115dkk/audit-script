# Workflow 구성 지침

resolve-audit를 Dynamic Workflow (ultracode)로 실행할 때의
서브에이전트 구성 방법.

## 병렬화 가능 범위

Category별 병렬화 가능 여부가 다르다.

**Category A (TDD)**: 항목 간 병렬화 불가. Red-Green-Refactor는
순차적 피드백 루프이며, 한 항목의 코드 변경이 다음 항목의
테스트에 영향을 줄 수 있다. 반드시 직렬로 처리.

**Category B (Refactor)**: 항목 간 파일이 겹치지 않으면 병렬
가능. 같은 파일을 건드리는 항목들은 직렬로 묶어야 한다.
의존성 그래프를 Phase 0에서 산출하고, 독립 그룹별로 서브에이전트
하나씩 할당.

**Category C (Config)**: 대부분 병렬 가능. 단, 같은 설정 파일을
수정하는 항목은 직렬로.

## 권장 워크플로 구조

```
Main Orchestrator (Opus 4.8, xhigh)
│
├── Phase 0: 분류 + 의존성 분석 (직렬, 메인이 직접 수행)
│
├── Phase 1: Category A 직렬 처리
│   └── A-1 → A-2 → A-3 (한 서브에이전트가 순차 실행)
│
├── Phase 2: Category B 병렬 처리
│   ├── SubAgent-B1: {B-1, B-4} (파일 겹침 없는 그룹 1)
│   ├── SubAgent-B2: {B-2, B-5} (그룹 2)
│   └── SubAgent-B3: {B-3}       (그룹 3)
│
├── Phase 3: Category C 병렬 처리
│   ├── SubAgent-C1: {C-1, C-2, C-3}
│   └── SubAgent-C2: {C-4, C-5}
│
├── Phase 4-review: 메인이 모든 커밋을 diff 리뷰
│
└── Phase 4-pr: PR 생성
```

## 서브에이전트 지침 템플릿

각 서브에이전트에 전달할 컨텍스트:

```
You are processing audit findings assigned to you.
Model: same as orchestrator (Opus 4.8)
Effort: same as orchestrator (xhigh)

Your assigned findings:
{finding list with IDs, descriptions, files}

Category: {A|B|C}
{category-specific protocol from SKILL.md Phase 1/2/3}

Rules:
- One commit per finding, prefixed with finding ID.
- Run tests after each commit (A, B) or linter (C).
- If a test fails unexpectedly, STOP and report back
  to the orchestrator. Do not attempt to fix it.
- Do not touch files outside your assigned scope.
```

## Producer-Skeptic 적용

Phase 4의 리뷰 단계에서 producer-skeptic 패턴을 적용한다.
서브에이전트(producer)가 커밋한 diff를 메인 오케스트레이터
(skeptic)가 검토한다. 검토 기준:

- Category A: 테스트가 구현이 아닌 행위를 검증하는가?
  최소한의 코드만 작성했는가? 테스트명이 행위를 서술하는가?
- Category B: 기존 테스트 pass count가 보존되었는가?
  공개 인터페이스가 변경되지 않았는가?
- Category C: 린터/컴파일러가 통과하는가?
  불필요한 코드 변경이 섞이지 않았는가?

리뷰에서 문제가 발견되면, 해당 커밋을 revert하고
서브에이전트에 수정 지시를 내린다. 문제가 발견되지
않으면 그대로 유지한다.

## 비용 고려

Workflow는 서브에이전트마다 독립 컨텍스트를 사용하므로
코드베이스 읽기 비용이 에이전트 수만큼 곱해진다.
Finding이 10개 미만이면 workflow 없이 단일 세션으로
처리하는 것이 비용 효율적이다. 10개 이상이고 Category B/C가
다수이며 파일 겹침이 적을 때 workflow가 정당화된다.
