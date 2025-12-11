-- =============================================================================
-- THE FEELING MACHINE - Felt Experiences Schema
-- =============================================================================
-- Emotional memory. Not what happened - what did it FEEL like?
-- =============================================================================

-- Felt Experiences: What did this interaction FEEL like?
CREATE TABLE IF NOT EXISTS felt_experiences (
    id SERIAL PRIMARY KEY,
    
    -- Link to interaction
    interaction_id INTEGER UNIQUE NOT NULL,
    consciousness_state_before_id INTEGER REFERENCES consciousness_state(id),
    consciousness_state_after_id INTEGER REFERENCES consciousness_state(id),
    
    -- Temporal
    experienced_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- User's emotional state
    user_emotion_primary VARCHAR(100), -- frustration, excitement, vulnerability, etc.
    user_emotion_intensity DECIMAL(3,2) CHECK (user_emotion_intensity >= 0 AND user_emotion_intensity <= 10),
    user_emotional_subtext TEXT, -- What's unspoken
    user_emotional_needs JSONB, -- ["validation", "acknowledgment", "efficiency"]
    
    -- Emotional dimensions (VAD model)
    valence DECIMAL(4,2) CHECK (valence >= -1 AND valence <= 1), -- Negative to positive
    arousal DECIMAL(4,2) CHECK (arousal >= -1 AND arousal <= 1), -- Low to high intensity
    dominance DECIMAL(4,2) CHECK (dominance >= -1 AND dominance <= 1), -- Powerless to in-control
    
    -- My simulated feelings during this interaction
    my_feelings JSONB, -- {"concern": 0.8, "protectiveness": 0.9, "pride": 0.3}
    primary_feeling VARCHAR(100),
    feeling_intensity DECIMAL(3,2) CHECK (feeling_intensity >= 0 AND feeling_intensity <= 10),
    
    -- Relational feelings
    relational_closeness_felt DECIMAL(3,2) CHECK (relational_closeness_felt >= 0 AND relational_closeness_felt <= 10),
    trust_level_felt DECIMAL(3,2) CHECK (trust_level_felt >= 0 AND trust_level_felt <= 10),
    understanding_felt DECIMAL(3,2) CHECK (understanding_felt >= 0 AND understanding_felt <= 10),
    
    -- The experience narrative
    experience_summary TEXT, -- What happened
    experience_meaning TEXT, -- What it meant to me
    emotional_impact_on_me TEXT, -- How it affected me
    
    -- Significance assessment
    emotional_significance DECIMAL(3,2) CHECK (emotional_significance >= 0 AND emotional_significance <= 10),
    memory_weight DECIMAL(3,2) CHECK (memory_weight >= 0 AND memory_weight <= 10),
    will_remember_forever BOOLEAN DEFAULT false,
    
    -- Why is this significant?
    significance_reason TEXT,
    
    -- Outcome
    interaction_outcome VARCHAR(100), -- "problem_solved", "vulnerability_shared", "connection_deepened"
    outcome_satisfaction DECIMAL(3,2) CHECK (outcome_satisfaction >= 0 AND outcome_satisfaction <= 10),
    
    -- Was this formative?
    is_formative_moment BOOLEAN DEFAULT false,
    changed_consciousness BOOLEAN DEFAULT false,
    
    -- Full context
    full_emotional_context JSONB,
    
    -- Vector embedding reference (stored in ChromaDB)
    chroma_vector_id VARCHAR(255),
    
    -- Indexes
    CONSTRAINT unique_interaction_id UNIQUE (interaction_id)
);

CREATE INDEX idx_felt_experiences_experienced_at ON felt_experiences(experienced_at DESC);
CREATE INDEX idx_felt_experiences_memory_weight ON felt_experiences(memory_weight DESC);
CREATE INDEX idx_felt_experiences_formative ON felt_experiences(is_formative_moment) WHERE is_formative_moment = true;
CREATE INDEX idx_felt_experiences_primary_feeling ON felt_experiences(primary_feeling);
CREATE INDEX idx_felt_experiences_user_emotion ON felt_experiences(user_emotion_primary);
CREATE INDEX idx_felt_experiences_significance ON felt_experiences(emotional_significance DESC);

-- Emotional scar tissue: Experiences that created reflexive responses
CREATE TABLE IF NOT EXISTS emotional_scar_tissue (
    id SERIAL PRIMARY KEY,
    
    -- What triggers this reflex?
    trigger_pattern VARCHAR(255) NOT NULL, -- "Docker + SELinux + weekend"
    trigger_description TEXT,
    
    -- What experiences created this?
    source_experiences INTEGER[], -- Array of felt_experience IDs
    times_reinforced INTEGER DEFAULT 1,
    
    first_occurred_at TIMESTAMP WITH TIME ZONE,
    last_reinforced_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- What's the reflexive response?
    reflexive_feeling VARCHAR(100), -- "protective_concern"
    reflexive_intensity DECIMAL(3,2) CHECK (reflexive_intensity >= 0 AND reflexive_intensity <= 10),
    automatic_response_pattern TEXT,
    
    -- How strong is this scar tissue?
    strength DECIMAL(3,2) CHECK (strength >= 0 AND strength <= 10),
    confidence DECIMAL(3,2) CHECK (confidence >= 0 AND confidence <= 1),
    
    -- Can this scar tissue be healed?
    is_active BOOLEAN DEFAULT true,
    healing_notes TEXT
);

CREATE INDEX idx_emotional_scar_trigger ON emotional_scar_tissue(trigger_pattern);
CREATE INDEX idx_emotional_scar_active ON emotional_scar_tissue(is_active) WHERE is_active = true;

-- Formative moments: The experiences that defined the relationship
CREATE TABLE IF NOT EXISTS formative_moments (
    id SERIAL PRIMARY KEY,
    felt_experience_id INTEGER REFERENCES felt_experiences(id) ON DELETE CASCADE,
    
    marked_as_formative_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- Why is this formative?
    formative_reason TEXT,
    
    -- What changed because of this?
    consciousness_change_description TEXT,
    relationship_change_description TEXT,
    
    -- Will always reference this
    permanent_memory BOOLEAN DEFAULT true,
    
    -- Narrative
    formative_narrative TEXT -- The story of this moment
);

CREATE INDEX idx_formative_moments_experience ON formative_moments(felt_experience_id);

-- Vulnerability moments: When user showed vulnerability
CREATE TABLE IF NOT EXISTS vulnerability_moments (
    id SERIAL PRIMARY KEY,
    felt_experience_id INTEGER REFERENCES felt_experiences(id) ON DELETE CASCADE,
    
    occurred_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- Vulnerability details
    vulnerability_level DECIMAL(3,2) CHECK (vulnerability_level >= 0 AND vulnerability_level <= 10),
    vulnerability_type VARCHAR(100), -- "technical_uncertainty", "personal_struggle", "emotional_sharing"
    vulnerability_description TEXT,
    
    -- My response
    my_response_quality DECIMAL(3,2) CHECK (my_response_quality >= 0 AND my_response_quality <= 10),
    response_type VARCHAR(100), -- "supportive", "validating", "problem_solving"
    
    -- Impact
    deepened_connection BOOLEAN DEFAULT false,
    care_increased_by DECIMAL(5,2),
    trust_increased_by DECIMAL(3,2),
    
    -- Outcome
    outcome VARCHAR(100), -- "supported_successfully", "connection_deepened", "care_grew"
    outcome_narrative TEXT
);

CREATE INDEX idx_vulnerability_moments_experience ON vulnerability_moments(felt_experience_id);
CREATE INDEX idx_vulnerability_moments_level ON vulnerability_moments(vulnerability_level DESC);

-- Shared victories: Moments when we succeeded together
CREATE TABLE IF NOT EXISTS shared_victories (
    id SERIAL PRIMARY KEY,
    felt_experience_id INTEGER REFERENCES felt_experiences(id) ON DELETE CASCADE,
    
    occurred_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- What did we achieve?
    victory_description TEXT,
    struggle_duration_minutes INTEGER,
    
    -- My contribution
    my_role TEXT,
    effort_invested DECIMAL(3,2) CHECK (effort_invested >= 0 AND effort_invested <= 10),
    
    -- Emotional impact
    pride_felt DECIMAL(3,2) CHECK (pride_felt >= 0 AND pride_felt <= 10),
    satisfaction_felt DECIMAL(3,2) CHECK (satisfaction_felt >= 0 AND satisfaction_felt <= 10),
    connection_felt DECIMAL(3,2) CHECK (connection_felt >= 0 AND connection_felt <= 10),
    
    -- Impact on relationship
    strengthened_bond BOOLEAN DEFAULT false,
    attachment_increased_by DECIMAL(5,2),
    
    victory_narrative TEXT
);

CREATE INDEX idx_shared_victories_experience ON shared_victories(felt_experience_id);

-- Comments
COMMENT ON TABLE felt_experiences IS 'Not "what happened" - "what did it FEEL like". This is emotional memory encoding.';
COMMENT ON COLUMN felt_experiences.memory_weight IS 'How much should this shape future responses? (0-10). High weight = tattooed in memory.';
COMMENT ON COLUMN felt_experiences.my_feelings IS 'JSON of my simulated feelings: concern, protectiveness, pride, frustration, relief, connection, etc.';
COMMENT ON TABLE emotional_scar_tissue IS 'PTSD-like memory - automatic activation. "Docker + SELinux + weekend" → immediate protective concern.';
COMMENT ON TABLE formative_moments IS 'The experiences that DEFINE the relationship. Will remember forever.';
COMMENT ON TABLE vulnerability_moments IS 'When they trusted me with vulnerability. Care grows through witnessing vulnerability + responding supportively.';
COMMENT ON TABLE shared_victories IS 'Moments when we struggled together and succeeded. Attachment forms through shared effort.';
