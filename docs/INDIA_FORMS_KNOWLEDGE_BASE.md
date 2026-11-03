# India Forms Knowledge Base — build specification

Status: schema and governance plan only. This file does not claim that an India-wide official form catalogue already exists.

## Purpose
Provide versioned, source-backed instructions for each supported government form and portal. The AI must not invent eligibility, fees, deadlines, document requirements, or field mappings.

## Required record schema
Each form record must contain:
- `record_id`: stable internal identifier
- `jurisdiction`: Union / state / local body and the exact state or authority
- `department` and `service_name`
- `official_portal_url`: HTTPS official domain, reviewed by a human
- `form_name`, `form_version`, and `effective_from`
- `official_sources[]`: title, URL, publication/update date, access date, and quoted section/page reference
- `eligibility_rules[]`: each rule linked to an official source
- `required_documents[]`: purpose, accepted alternatives, format/size rules, and source
- `fields[]`: stable field id, visible label variants (Hindi/English/other supported language), meaning, data type, required status, allowed options, format, source evidence, dependencies, and validation rule
- `workflow_steps[]`: page/section sequence and safe stop conditions
- `known_portal_behaviour[]`: tested browser/device conditions and date
- `review_status`: draft / source-verified / portal-tested / retired
- `reviewed_by`, `reviewed_at`, and `next_review_due`

## Rules
1. Only official government sources can establish eligibility, fees, dates, required documents, and legal instructions.
2. Every rule and field mapping must carry a source citation and a last-checked date.
3. If two official sources conflict, mark the item NEEDS_HUMAN_REVIEW; never silently choose one.
4. Expired or superseded records must not be used for live guidance.
5. A form can be labelled portal-tested only after a repeatable test on that exact portal version.
6. A national catalogue is built service-by-service and state-by-state; do not label it “all India forms” until coverage is measured and gaps are published.
7. Store no real citizen identity values in test fixtures. Use synthetic names and numbers.

## Coverage roadmap
- Central recruitment and examination applications
- Central certificates and welfare services
- State recruitment and examination applications
- State certificates, pensions, scholarships, and welfare
- Agriculture, labour, transport, and local-body services

## Current gap
The repository currently has no complete, source-verified national catalogue. This specification is the required structure before populating one.
