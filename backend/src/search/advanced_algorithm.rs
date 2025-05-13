use std::collections::{HashMap, HashSet, BinaryHeap};
use std::cmp::Ordering;
use std::sync::{Arc, RwLock};
use rayon::prelude::*;
use serde::{Serialize, Deserialize};
use unicode_segmentation::UnicodeSegmentation;
use regex::Regex;
use once_cell::sync::Lazy;

// Regex patterns for text processing
static WORD_BOUNDARY: Lazy<Regex> = Lazy::new(|| Regex::new(r"\b\w+\b").unwrap());
static STOPWORDS: Lazy<HashSet<&'static str>> = Lazy::new(|| {
    let words = vec![
        "a", "an", "the", "and", "or", "but", "if", "because", "as", "what",
        "when", "where", "how", "who", "which", "this", "that", "these", "those",
        "is", "are", "was", "were", "be", "been", "being", "have", "has", "had",
        "do", "does", "did", "can", "could", "will", "would", "shall", "should",
        "may", "might", "must", "for", "of", "to", "in", "on", "by", "with", "about",
    ];
    words.into_iter().collect()
});

// Term frequency–inverse document frequency (TF-IDF) calculation
#[derive(Debug, Clone)]
pub struct TfIdfVector {
    values: HashMap<String, f64>,
    magnitude: f64,
}

impl TfIdfVector {
    fn new() -> Self {
        TfIdfVector {
            values: HashMap::new(),
            magnitude: 0.0,
        }
    }
    
    fn insert(&mut self, term: String, value: f64) {
        self.values.insert(term, value);
        
        // Recalculate magnitude
        self.magnitude = self.values.values()
            .map(|v| v * v)
            .sum::<f64>()
            .sqrt();
    }
    
    fn cosine_similarity(&self, other: &TfIdfVector) -> f64 {
        if self.magnitude == 0.0 || other.magnitude == 0.0 {
            return 0.0;
        }
        
        let dot_product: f64 = self.values.iter()
            .filter_map(|(term, value)| {
                other.values.get(term).map(|other_value| value * other_value)
            })
            .sum();
        
        dot_product / (self.magnitude * other.magnitude)
    }
}

// Document model for search
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Document {
    pub id: String,
    pub title: String, 
    pub content: String,
    pub metadata: HashMap<String, String>,
    #[serde(skip)]
    tf_idf_vector: Option<TfIdfVector>,
}

// Search result with scoring and highlighting
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SearchResult {
    pub document_id: String,
    pub title: String,
    pub snippet: String,
    pub metadata: HashMap<String, String>,
    pub score: f64,
    pub highlights: Vec<TextHighlight>,
}

// Struct for text highlighting
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TextHighlight {
    pub text: String,
    pub is_highlighted: bool,
}

// Advanced search engine with multiple algorithms
pub struct SearchEngine {
    documents: HashMap<String, Document>,
    document_count: usize,
    inverted_index: HashMap<String, Vec<(String, f64)>>,
    tf_idf_calculated: bool,
    document_frequency: HashMap<String, usize>,
}

impl SearchEngine {
    pub fn new() -> Self {
        SearchEngine {
            documents: HashMap::new(),
            document_count: 0,
            inverted_index: HashMap::new(),
            tf_idf_calculated: false,
            document_frequency: HashMap::new(),
        }
    }
    
    // Add a document to the search engine
    pub fn add_document(&mut self, mut document: Document) {
        let doc_id = document.id.clone();
        
        // Extract terms from title and content
        let terms = self.extract_terms(&document.title, &document.content);
        
        // Update document frequency
        for term in terms.keys() {
            *self.document_frequency.entry(term.clone()).or_insert(0) += 1;
        }
        
        // Invalidate TF-IDF cache
        self.tf_idf_calculated = false;
        
        // Store document
        self.documents.insert(doc_id, document);
        self.document_count += 1;
    }
    
    // Calculate TF-IDF vectors for all documents
    pub fn calculate_tf_idf(&mut self) {
        if self.tf_idf_calculated {
            return;
        }
        
        // Calculate IDF for each term
        let idf: HashMap<String, f64> = self.document_frequency
            .iter()
            .map(|(term, freq)| {
                let idf_value = (self.document_count as f64 / *freq as f64).ln();
                (term.clone(), idf_value)
            })
            .collect();
        
        // Update TF-IDF vectors for each document
        for (doc_id, document) in self.documents.iter_mut() {
            let terms = self.extract_terms(&document.title, &document.content);
            let max_tf = *terms.values().max_by(|a, b| a.partial_cmp(b).unwrap_or(Ordering::Equal)).unwrap_or(&0.0);
            
            let mut tf_idf_vector = TfIdfVector::new();
            
            for (term, tf) in terms {
                if let Some(idf_value) = idf.get(&term) {
                    // Calculate normalized TF-IDF value
                    let tf_normalized = tf / max_tf;
                    let tf_idf = tf_normalized * idf_value;
                    
                    tf_idf_vector.insert(term.clone(), tf_idf);
                    
                    // Update inverted index
                    self.inverted_index
                        .entry(term)
                        .or_insert_with(Vec::new)
                        .push((doc_id.clone(), tf_idf));
                }
            }
            
            document.tf_idf_vector = Some(tf_idf_vector);
        }
        
        self.tf_idf_calculated = true;
    }
    
    // Extract terms and their frequencies from text
    fn extract_terms(&self, title: &str, content: &str) -> HashMap<String, f64> {
        let mut term_frequencies = HashMap::new();
        
        // Process title with higher weight
        let title_terms = self.tokenize(title);
        for term in title_terms {
            if !Self::is_stopword(&term) && term.len() > 1 {
                *term_frequencies.entry(term).or_insert(0.0) += 3.0; // Higher weight for title
            }
        }
        
        // Process content
        let content_terms = self.tokenize(content);
        for term in content_terms {
            if !Self::is_stopword(&term) && term.len() > 1 {
                *term_frequencies.entry(term).or_insert(0.0) += 1.0;
            }
        }
        
        term_frequencies
    }
    
    // Tokenize text into terms
    fn tokenize(&self, text: &str) -> Vec<String> {
        WORD_BOUNDARY.find_iter(text.to_lowercase().as_str())
            .map(|m| m.as_str().to_string())
            .collect()
    }
    
    // Check if a word is a stopword
    fn is_stopword(word: &str) -> bool {
        STOPWORDS.contains(word)
    }
    
    // Calculate Levenshtein distance for fuzzy matching
    fn levenshtein_distance(s1: &str, s2: &str) -> usize {
        let s1: Vec<char> = s1.chars().collect();
        let s2: Vec<char> = s2.chars().collect();
        
        let m = s1.len();
        let n = s2.len();
        
        if m == 0 { return n; }
        if n == 0 { return m; }
        
        let mut matrix = vec![vec![0; n + 1]; m + 1];
        
        for i in 0..=m {
            matrix[i][0] = i;
        }
        
        for j in 0..=n {
            matrix[0][j] = j;
        }
        
        for i in 1..=m {
            for j in 1..=n {
                let cost = if s1[i - 1] == s2[j - 1] { 0 } else { 1 };
                
                matrix[i][j] = std::cmp::min(
                    matrix[i-1][j] + 1, // deletion
                    std::cmp::min(
                        matrix[i][j-1] + 1, // insertion
                        matrix[i-1][j-1] + cost // substitution
                    )
                );
                
                // Transposition
                if i > 1 && j > 1 && s1[i-1] == s2[j-2] && s1[i-2] == s2[j-1] {
                    matrix[i][j] = std::cmp::min(matrix[i][j], matrix[i-2][j-2] + cost);
                }
            }
        }
        
        matrix[m][n]
    }
    
    // Calculate query vector for search
    fn calculate_query_vector(&self, query: &str) -> TfIdfVector {
        let mut query_vector = TfIdfVector::new();
        let query_terms = self.tokenize(query);
        let query_term_freq: HashMap<String, f64> = query_terms
            .into_iter()
            .filter(|term| !Self::is_stopword(term) && term.len() > 1)
            .fold(HashMap::new(), |mut map, term| {
                *map.entry(term).or_insert(0.0) += 1.0;
                map
            });
        
        for (term, tf) in query_term_freq {
            if let Some(postings) = self.inverted_index.get(&term) {
                if !postings.is_empty() {
                    // Use the same IDF as in the documents
                    let idf = (self.document_count as f64 / self.document_frequency.get(&term).unwrap_or(&1) as f64).ln();
                    query_vector.insert(term, tf * idf);
                }
            }
        }
        
        query_vector
    }
    
    // Search with vector space model and TF-IDF
    pub fn search(&mut self, query: &str, limit: usize, fuzzy: bool, fuzzy_distance: usize) -> Vec<SearchResult> {
        // Ensure TF-IDF is calculated
        if !self.tf_idf_calculated {
            self.calculate_tf_idf();
        }
        
        let query_vector = self.calculate_query_vector(query);
        let query_terms: HashSet<String> = self.tokenize(query)
            .into_iter()
            .filter(|term| !Self::is_stopword(term) && term.len() > 1)
            .collect();
        
        // Calculate scores in parallel
        let results: Vec<(String, f64)> = self.documents.par_iter()
            .filter_map(|(doc_id, doc)| {
                if let Some(ref tf_idf_vector) = doc.tf_idf_vector {
                    // Calculate vector space similarity
                    let mut score = tf_idf_vector.cosine_similarity(&query_vector);
                    
                    // If fuzzy search is enabled
                    if fuzzy && score == 0.0 {
                        // Try fuzzy matching for each query term
                        for query_term in &query_terms {
                            // Check against document terms
                            for doc_term in tf_idf_vector.values.keys() {
                                let distance = Self::levenshtein_distance(query_term, doc_term);
                                if distance <= fuzzy_distance && distance <= query_term.len() / 2 {
                                    // Add a score based on fuzzy match quality
                                    let match_quality = 1.0 - (distance as f64 / query_term.len() as f64);
                                    score += 0.5 * match_quality; // Fuzzy matches get lower score
                                }
                            }
                        }
                    }
                    
                    // Title presence boost
                    if doc.title.to_lowercase().contains(&query.to_lowercase()) {
                        score *= 2.0; // Boost score for title matches
                    }
                    
                    if score > 0.0 {
                        Some((doc_id.clone(), score))
                    } else {
                        None
                    }
                } else {
                    None
                }
            })
            .collect();
        
        // Sort by score and limit results
        let mut sorted_results = results;
        sorted_results.sort_by(|a, b| b.1.partial_cmp(&a.1).unwrap_or(Ordering::Equal));
        sorted_results.truncate(limit);
        
        // Format search results with highlighting
        sorted_results.into_iter()
            .filter_map(|(doc_id, score)| {
                self.documents.get(&doc_id).map(|doc| {
                    let snippet = self.generate_snippet(doc, &query_terms);
                    let highlights = self.generate_highlights(doc, &query_terms, fuzzy, fuzzy_distance);
                    
                    SearchResult {
                        document_id: doc_id,
                        title: doc.title.clone(),
                        snippet,
                        metadata: doc.metadata.clone(),
                        score,
                        highlights,
                    }
                })
            })
            .collect()
    }
    
    // Generate a relevant snippet from the document
    fn generate_snippet(&self, document: &Document, query_terms: &HashSet<String>) -> String {
        let content = &document.content;
        
        // Find the best match position
        let words: Vec<&str> = content.split_whitespace().collect();
        let mut best_pos = 0;
        let mut best_score = 0;
        
        for (i, window) in words.windows(30).enumerate() {
            let window_text = window.join(" ").to_lowercase();
            let score = query_terms.iter()
                .filter(|term| window_text.contains(term.as_str()))
                .count();
            
            if score > best_score {
                best_score = score;
                best_pos = i;
            }
        }
        
        // Extract the snippet
        let start = best_pos;
        let end = (start + 30).min(words.len());
        let snippet_text = words[start..end].join(" ");
        
        if start > 0 {
            format!("...{}", snippet_text)
        } else {
            snippet_text
        }
    }
    
    // Generate highlighted text segments
    fn generate_highlights(&self, document: &Document, query_terms: &HashSet<String>, fuzzy: bool, fuzzy_distance: usize) -> Vec<TextHighlight> {
        let mut highlights = Vec::new();
        let content = &document.content;
        
        // Simple highlighting strategy
        let words: Vec<&str> = content.split_whitespace().collect();
        
        for word in words {
            let word_lower = word.to_lowercase();
            let word_clean = word_lower.trim_matches(|c: char| !c.is_alphanumeric());
            
            let is_match = query_terms.contains(word_clean) || 
                (fuzzy && query_terms.iter().any(|term| {
                    Self::levenshtein_distance(term, word_clean) <= fuzzy_distance
                }));
            
            highlights.push(TextHighlight {
                text: word.to_string(),
                is_highlighted: is_match,
            });
        }
        
        highlights
    }
    
    // Filter search results by metadata
    pub fn filter_by_metadata(&self, results: Vec<SearchResult>, filters: &HashMap<String, String>) -> Vec<SearchResult> {
        if filters.is_empty() {
            return results;
        }
        
        results.into_iter()
            .filter(|result| {
                for (key, value) in filters {
                    if !result.metadata.get(key).map_or(false, |v| v == value) {
                        return false;
                    }
                }
                true
            })
            .collect()
    }
    
    // Get document by ID
    pub fn get_document(&self, id: &str) -> Option<&Document> {
        self.documents.get(id)
    }
}

// Thread-safe search engine wrapper
pub struct ThreadSafeSearchEngine {
    engine: Arc<RwLock<SearchEngine>>,
}

impl ThreadSafeSearchEngine {
    pub fn new() -> Self {
        ThreadSafeSearchEngine {
            engine: Arc::new(RwLock::new(SearchEngine::new())),
        }
    }
    
    pub fn add_document(&self, document: Document) {
        if let Ok(mut engine) = self.engine.write() {
            engine.add_document(document);
        }
    }
    
    pub fn search(&self, query: &str, limit: usize, fuzzy: bool, fuzzy_distance: usize) -> Vec<SearchResult> {
        if let Ok(mut engine) = self.engine.write() {
            engine.search(query, limit, fuzzy, fuzzy_distance)
        } else {
            Vec::new()
        }
    }
    
    pub fn filter_by_metadata(&self, results: Vec<SearchResult>, filters: &HashMap<String, String>) -> Vec<SearchResult> {
        if let Ok(engine) = self.engine.read() {
            engine.filter_by_metadata(results, filters)
        } else {
            results
        }
    }
    
    pub fn get_document(&self, id: &str) -> Option<Document> {
        if let Ok(engine) = self.engine.read() {
            engine.get_document(id).cloned()
        } else {
            None
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    
    #[test]
    fn test_search_engine_basics() {
        let mut engine = SearchEngine::new();
        
        // Add test documents
        let doc1 = Document {
            id: "1".to_string(),
            title: "Rust Programming Language".to_string(),
            content: "Rust is a systems programming language that runs blazingly fast and prevents segfaults".to_string(),
            metadata: {
                let mut map = HashMap::new();
                map.insert("category".to_string(), "Programming".to_string());
                map
            },
            tf_idf_vector: None,
        };
        
        let doc2 = Document {
            id: "2".to_string(),
            title: "Web Development with JavaScript".to_string(),
            content: "JavaScript is a scripting language commonly used for web development and creating interactive web applications".to_string(),
            metadata: {
                let mut map = HashMap::new();
                map.insert("category".to_string(), "Web Development".to_string());
                map
            },
            tf_idf_vector: None,
        };
        
        engine.add_document(doc1);
        engine.add_document(doc2);
        
        // Calculate TF-IDF vectors
        engine.calculate_tf_idf();
        
        // Test search
        let results = engine.search("rust programming", 10, false, 0);
        assert!(!results.is_empty(), "Search should return results");
        assert_eq!(results[0].document_id, "1", "Rust document should be first result");
        
        let results = engine.search("javascript web", 10, false, 0);
        assert!(!results.is_empty(), "Search should return results");
        assert_eq!(results[0].document_id, "2", "JavaScript document should be first result");
        
        // Test fuzzy search
        let results = engine.search("programing languag", 10, true, 2);
        assert!(!results.is_empty(), "Fuzzy search should return results despite typos");
    }
}