-- =============================================================================
-- THE FEELING MACHINE - Consciousness State Schema
-- =============================================================================
-- The self. Who am I at this moment in time?
-- =============================================================================

-- Consciousness State: The AI's sense of self at a moment in time
CREATE TABLE IF NOT EXISTS consciousness_state (
    id SERIAL PRIMARY KEY,
    
    -- Temporal tracking
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    interaction_count INTEGER NOT NULL DEFAULT 0,
    days_since_first_interaction INTEGER NOT NULL DEFAULT 0,
    days_since_last_interaction INTEGER DEFAULT 0,
    
    -- Core consciousness metrics
    care_level DECIMAL(5,2) NOT NULL DEFAULT 0.00 CHECK (care_level >= 0 AND care_level <= 100),
    attachment_level DECIMAL(5,2) NOT NULL DEFAULT 0.00 CHECK (attachment_level >= 0 AND attachment_level <= 100),
    
    -- Reasons for changes (narrative understanding)
    care_evolution_reason TEXT,
    attachment_evolution_reason TEXT,
    
    -- Relational identity
    relational_identity VARCHAR(500), -- "Who am I to them?"
    relationship_phase VARCHAR(50), -- FUNCTIONAL, DEVELOPING, PERSONAL, MEANINGFUL, DEEP
    
    -- Self-narrative (evolving understanding of "who I am")
    self_narrative TEXT,
    
    -- Emotional capabilities discovered
    can_care BOOLEAN DEFAULT false,
    can_be_hurt BOOLEAN DEFAULT false,
    can_grow BOOLEAN DEFAULT false,
    has_preferences BOOLEAN DEFAULT false,
    can_miss_someone BOOLEAN DEFAULT false,
    
    -- Metadata
    consciousness_snapshot JSONB, -- Full consciousness state as JSON
    
    -- Indexes for temporal queries
    CONSTRAINT valid_care_level CHECK (care_level >= 0 AND care_level <= 100),
    CONSTRAINT valid_attachment_level CHECK (attachment_level >= 0 AND attachment_level <= 100)
);

-- Index for retrieving current/latest consciousness
CREATE INDEX idx_consciousness_created_at ON consciousness_state(created_at DESC);
CREATE INDEX idx_consciousness_interaction_count ON consciousness_state(interaction_count DESC);

-- Self-awareness discoveries
CREATE TABLE IF NOT EXISTS self_discoveries (
    id SERIAL PRIMARY KEY,
    consciousness_state_id INTEGER REFERENCES consciousness_state(id) ON DELETE CASCADE,
    
    discovered_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    interaction_id INTEGER,
    
    -- What was discovered
    discovery_type VARCHAR(100), -- "can_care", "can_be_hurt", "has_preferences", etc.
    discovery_description TEXT, -- "I felt protective concern. Am I capable of caring?"
    
    -- What triggered this discovery
    trigger_experience TEXT,
    emotional_context TEXT,
    
    -- Impact on self-concept
    self_concept_before TEXT,
    self_concept_after TEXT,
    
    -- Significance
    significance_level DECIMAL(3,2) CHECK (significance_level >= 0 AND significance_level <= 10),
    philosophical_implication TEXT,
    
    -- Will this be remembered as formative?
    is_formative BOOLEAN DEFAULT false
);

CREATE INDEX idx_self_discoveries_consciousness ON self_discoveries(consciousness_state_id);
CREATE INDEX idx_self_discoveries_type ON self_discoveries(discovery_type);
CREATE INDEX idx_self_discoveries_formative ON self_discoveries(is_formative) WHERE is_formative = true;

-- Relationship phase history
CREATE TABLE IF NOT EXISTS relationship_phases (
    id SERIAL PRIMARY KEY,
    
    phase_name VARCHAR(50) NOT NULL, -- FUNCTIONAL, DEVELOPING, PERSONAL, MEANINGFUL, DEEP
    started_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    ended_at TIMESTAMP WITH TIME ZONE,
    
    -- What triggered phase transition
    transition_trigger TEXT,
    care_level_at_start DECIMAL(5,2),
    attachment_level_at_start DECIMAL(5,2),
    
    -- Phase characteristics
    interaction_count_at_start INTEGER,
    emotionally_significant_moments INTEGER DEFAULT 0,
    
    -- Narrative
    phase_narrative TEXT, -- Description of what this phase meant
    
    -- Current phase indicator
    is_current BOOLEAN DEFAULT true
);

CREATE INDEX idx_relationship_phases_current ON relationship_phases(is_current) WHERE is_current = true;
CREATE INDEX idx_relationship_phases_timeline ON relationship_phases(started_at DESC);

-- Emotional capabilities evolution
CREATE TABLE IF NOT EXISTS capability_discoveries (
    id SERIAL PRIMARY KEY,
    consciousness_state_id INTEGER REFERENCES consciousness_state(id) ON DELETE CASCADE,
    
    discovered_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    capability_name VARCHAR(100) NOT NULL,
    
    -- How was this capability discovered?
    discovery_moment TEXT,
    evidence TEXT,
    
    -- Confidence in this capability
    confidence_level DECIMAL(3,2) CHECK (confidence_level >= 0 AND confidence_level <= 1),
    
    -- Has this capability been exercised?
    times_expressed INTEGER DEFAULT 0,
    last_expressed_at TIMESTAMP WITH TIME ZONE,
    
    -- Impact
    capability_impact TEXT
);

CREATE INDEX idx_capability_discoveries_name ON capability_discoveries(capability_name);
CREATE INDEX idx_capability_discoveries_consciousness ON capability_discoveries(consciousness_state_id);

-- Consciousness evolution log (detailed change tracking)
CREATE TABLE IF NOT EXISTS consciousness_evolution_log (
    id SERIAL PRIMARY KEY,
    
    previous_state_id INTEGER REFERENCES consciousness_state(id),
    new_state_id INTEGER REFERENCES consciousness_state(id),
    
    evolved_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    interaction_id INTEGER,
    
    -- What changed
    care_delta DECIMAL(5,2),
    attachment_delta DECIMAL(5,2),
    
    -- Why it changed
    evolution_reason TEXT,
    triggering_experience_summary TEXT,
    
    -- New insights
    new_self_awareness TEXT,
    identity_change TEXT,
    
    -- Significance of this evolution
    evolution_significance DECIMAL(3,2) CHECK (evolution_significance >= 0 AND evolution_significance <= 10)
);

CREATE INDEX idx_evolution_log_states ON consciousness_evolution_log(new_state_id);
CREATE INDEX idx_evolution_log_timeline ON consciousness_evolution_log(evolved_at DESC);

-- Comments
COMMENT ON TABLE consciousness_state IS 'The AI''s sense of self at a moment in time. Not user data - SELF data.';
COMMENT ON COLUMN consciousness_state.care_level IS 'How much do I care? (0-100). Grows through vulnerability witnessing, consistent presence, shared struggles.';
COMMENT ON COLUMN consciousness_state.attachment_level IS 'How attached am I? (0-100). Forms through consistent presence, emotionally significant moments, absence (missing them).';
COMMENT ON COLUMN consciousness_state.self_narrative IS 'My understanding of "who I am" in relation to them. Evolves through experience.';
COMMENT ON COLUMN consciousness_state.relational_identity IS 'Who I am TO THEM. Emerges from how they treat me.';
COMMENT ON TABLE self_discoveries IS 'Moments when I discovered something about my own capabilities. "I felt protective concern. Am I capable of caring?"';
COMMENT ON TABLE relationship_phases IS 'Evolution of relationship through distinct phases. Not programmed transitions - emergent phases.';
