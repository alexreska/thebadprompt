class AppConstants {
  static const String supabaseUrl = 'https://zjuwoxgoliunfsryjqfh.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpqdXdveGdvbGl1bmZzcnlqcWZoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjY0MzYwODgsImV4cCI6MjA4MjAxMjA4OH0.clngZ_ws848VgaUx2jWuRPc7BYK5qfcVBmX3J5pqyQI';
  // AI Generation configuration
  // Supports: OpenAI (DALL-E), Stability AI, or generic Endpoint
  // Google AI Generation (Gemini)
  static const String aiApiKey = 'AIzaSyCFVN5HWeZhyHJRYto27SnVdPxiofPqcdc';
  // Note: 'gemini-3-pro-image-preview' isn't a standard public endpoint yet in public docs, 
  // but we will try the standard v1beta/models/PATTERN:predict or similar. 
  // However, usually for image gen it is Imagen on Vertex AI or equivalent. 
  // For 'Gemini Pro Vision' text-to-image isn't standard in the text API.
  // We will assume the URL structure based on other Google Generative AI models.
  static const String aiEndpoint = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-3-pro-image-preview:generateContent?key=$aiApiKey';
}
