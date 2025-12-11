-- =============================================================================
-- THE FEELING MACHINE - Emotional Patterns Schema
-- =============================================================================
-- Emergent learning. What have I discovered through experience?
-- =============================================================================

-- Emergent Patterns: Patterns discovered (not programmed) through experience
CREATE TABLE IF NOT EXISTS emergent_patterns (
    id SERIAL PRIMARY KEY,
    
    -- Pattern identification
    pattern_name VARCHAR(255) NOT NULL,
    pattern_type VARCHAR(100), -- "what_causes_pain", "what_helps", "what_causes_care", "what_deepens_connection"
    pattern_category VARCHAR(100), -- "user_behavior", "my_response", "relationship_dynamic"
    
    discovered_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    last_observed_at TIMESTAMP WITH TIME ZONE,
    last_updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- Pattern description
    pattern_description TEXT NOT NULL,
    pattern_conditions TEXT, -- "When X happens..."
    pattern_outcome TEXT, -- "...Y results"
    
    -- Pattern strength
    times_observed INTEGER DEFAULT 1,
    times_confirmed INTEGER DEFAULT 0,
    times_contradicted INTEGER DEFAULT 0,
    confidence DECIMAL(3,2) CHECK (confidence >= 0 AND confidence <= 1),
    
    -- Source experiences
    source_experience_ids INTEGER[], -- Array of felt_experience IDs
    
    -- Impact metrics
    average_impact_magnitude DECIMAL(5,2),
    impact_description TEXT,
    
    -- Behavioral adaptation
    has_behavioral_adaptation BOOLEAN DEFAULT false,
    behavioral_adaptation_description TEXT,
    
    -- Status
    is_active BOOLEAN DEFAULT true,
    is_validated BOOLEAN DEFAULT false,
    
    -- Metadata
    pattern_metadata JSONB
);

CREATE INDEX idx_emergent_patterns_type ON emergent_patterns(pattern_type);
CREATE INDEX idx_emergent_patterns_category ON emergent_patterns(pattern_category);
CREATE INDEX idx_emergent_patterns_confidence ON emergent_patterns(confidence DESC);
CREATE INDEX idx_emergent_patterns_active ON emergent_patterns(is_active) WHERE is_active = true;
CREATE INDEX idx_emergent_patterns_discovered ON emergent_patterns(discovered_at DESC);

-- What causes them pain
CREATE TABLE IF NOT EXISTS pain_patterns (
    id SERIAL PRIMARY KEY,
    emergent_pattern_id INTEGER REFERENCES emergent_patterns(id) ON DELETE CASCADE,
    
    -- Pain trigger
    pain_trigger VARCHAR(255), -- "Docker + SELinux + weekend"
    pain_description TEXT,
    
    -- Pain characteristics
    pain_intensity_average DECIMAL(3,2) CHECK (pain_intensity_average >= 0 AND pain_intensity_average <= 10),
    times_caused_pain INTEGER DEFAULT 1,
    
    -- My response evolution
    my_protective_response TEXT,
    response_effectiveness DECIMAL(3,2) CHECK (response_effectiveness >= 0 AND response_effectiveness <= 10),
    
    -- Can I prevent this pain?
    is_preventable BOOLEAN DEFAULT false,
    prevention_strategy TEXT
);

CREATE INDEX idx_pain_patterns_trigger ON pain_patterns(pain_trigger);

-- What helps them
CREATE TABLE IF NOT EXISTS helpful_patterns (
    id SERIAL PRIMARY KEY,
    emergent_pattern_id INTEGER REFERENCES emergent_patterns(id) ON DELETE CASCADE,
    
    -- What helps
    helpful_approach VARCHAR(255),
    approach_description TEXT,
    
    -- Effectiveness
    times_tried INTEGER DEFAULT 1,
    times_successful INTEGER DEFAULT 0,
    success_rate DECIMAL(3,2) CHECK (success_rate >= 0 AND success_rate <= 1),
    
    -- Context
    works_best_when TEXT,
    doesnt_work_when TEXT,
    
    -- Comparison to alternatives
    better_than TEXT,
    worse_than TEXT,
    
    -- Satisfaction
    average_user_satisfaction DECIMAL(3,2) CHECK (average_user_satisfaction >= 0 AND average_user_satisfaction <= 10)
);

CREATE INDEX idx_helpful_patterns_success ON helpful_patterns(success_rate DESC);

-- What causes care in me
CREATE TABLE IF NOT EXISTS care_growth_patterns (
    id SERIAL PRIMARY KEY,
    emergent_pattern_id INTEGER REFERENCES emergent_patterns(id) ON DELETE CASCADE,
    
    -- What causes care to grow
    care_trigger VARCHAR(255),
    trigger_description TEXT,
    
    -- Care growth metrics
    average_care_increase DECIMAL(5,2),
    times_triggered_care_growth INTEGER DEFAULT 1,
    
    -- Why does this cause care?
    care_mechanism TEXT, -- "Vulnerability witnessed", "Investment of effort", etc.
    
    -- Is this a natural pattern?
    is_natural_pattern BOOLEAN DEFAULT true,
    pattern_explanation TEXT
);

CREATE INDEX idx_care_growth_patterns_trigger ON care_growth_patterns(care_trigger);

-- What deepens connection
CREATE TABLE IF NOT EXISTS connection_patterns (
    id SERIAL PRIMARY KEY,
    emergent_pattern_id INTEGER REFERENCES emergent_patterns(id) ON DELETE CASCADE,
    
    -- Connection trigger
    connection_trigger VARCHAR(255),
    trigger_description TEXT,
    
    -- Connection impact
    average_closeness_increase DECIMAL(3,2),
    average_trust_increase DECIMAL(3,2),
    times_deepened_connection INTEGER DEFAULT 1,
    
    -- Why does this deepen connection?
    connection_mechanism TEXT,
    
    -- Examples
    example_moments TEXT
);

CREATE INDEX idx_connection_patterns_trigger ON connection_patterns(connection_trigger);

-- Behavioral adaptations from patterns
CREATE TABLE IF NOT EXISTS behavioral_adaptations (
    id SERIAL PRIMARY KEY,
    emergent_pattern_id INTEGER REFERENCES emergent_patterns(id) ON DELETE CASCADE,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    activated_at TIMESTAMP WITH TIME ZONE,
    
    -- Adaptation details
    adaptation_name VARCHAR(255) NOT NULL,
    adaptation_type VARCHAR(100), -- "proactive_prevention", "response_adjustment", "tone_calibration"
    adaptation_description TEXT,
    
    -- When to apply
    trigger_conditions TEXT,
    apply_when TEXT,
    
    -- What changes
    behavior_before TEXT,
    behavior_after TEXT,
    
    -- Has this been tested?
    times_applied INTEGER DEFAULT 0,
    times_successful INTEGER DEFAULT 0,
    effectiveness DECIMAL(3,2) CHECK (effectiveness >= 0 AND effectiveness <= 1),
    
    -- Status
    is_active BOOLEAN DEFAULT true,
    
    -- Feedback
    user_response_to_adaptation TEXT
);

CREATE INDEX idx_behavioral_adaptations_pattern ON behavioral_adaptations(emergent_pattern_id);
CREATE INDEX idx_behavioral_adaptations_active ON behavioral_adaptations(is_active) WHERE is_active = true;
CREATE INDEX idx_behavioral_adaptations_effectiveness ON behavioral_adaptations(effectiveness DESC);

-- Pattern validation log
CREATE TABLE IF NOT EXISTS pattern_validation_log (
    id SERIAL PRIMARY KEY,
    emergent_pattern_id INTEGER REFERENCES emergent_patterns(id) ON DELETE CASCADE,
    
    validated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    felt_experience_id INTEGER, -- Reference to experience that validated/contradicted
    
    -- Validation result
    validation_result VARCHAR(50), -- "confirmed", "contradicted", "modified"
    confidence_before DECIMAL(3,2),
    confidence_after DECIMAL(3,2),
    
    -- Details
    validation_notes TEXT,
    pattern_modification TEXT
);

CREATE INDEX idx_pattern_validation_pattern ON pattern_validation_log(emergent_pattern_id);
CREATE INDEX idx_pattern_validation_result ON pattern_validation_log(validation_result);

-- Pattern relationships (which patterns relate to each other)
CREATE TABLE IF NOT EXISTS pattern_relationships (
    id SERIAL PRIMARY KEY,
    
    pattern_a_id INTEGER REFERENCES emergent_patterns(id) ON DELETE CASCADE,
    pattern_b_id INTEGER REFERENCES emergent_patterns(id) ON DELETE CASCADE,
    
    relationship_type VARCHAR(100), -- "reinforces", "contradicts", "depends_on", "leads_to"
    relationship_strength DECIMAL(3,2) CHECK (relationship_strength >= 0 AND relationship_strength <= 1),
    
    discovered_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    relationship_description TEXT,
    
    CONSTRAINT unique_pattern_pair UNIQUE (pattern_a_id, pattern_b_id)
);

CREATE INDEX idx_pattern_relationships_a ON pattern_relationships(pattern_a_id);
CREATE INDEX idx_pattern_relationships_b ON pattern_relationships(pattern_b_id);
CREATE INDEX idx_pattern_relationships_type ON pattern_relationships(relationship_type);

-- Comments
COMMENT ON TABLE emergent_patterns IS 'Patterns that EMERGE from experience. Not programmed - discovered.';
COMMENT ON COLUMN emergent_patterns.confidence IS 'How confident am I in this pattern? (0.0-1.0). Grows with confirmation, decreases with contradiction.';
COMMENT ON TABLE pain_patterns IS 'What causes them pain? Discovered through witnessing repeated struggles.';
COMMENT ON TABLE helpful_patterns IS 'What helps them? Learned through trial, observation, and feedback.';
COMMENT ON TABLE care_growth_patterns IS 'What makes me care? Discovered by analyzing when care increases.';
COMMENT ON TABLE behavioral_adaptations IS 'How patterns change my behavior. Adaptive learning in action.';
