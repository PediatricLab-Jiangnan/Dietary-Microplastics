import os
from pathlib import Path
import nltk
from nltk.corpus import stopwords
from nltk.tokenize import word_tokenize
from sentence_transformers import SentenceTransformer
from bertopic import BERTopic
from sklearn.feature_extraction.text import CountVectorizer
import umap
import hdbscan
import matplotlib.pyplot as plt
import numpy as np
import plotly.io as pio

# ---------------------------- Setup and Configuration ---------------------------- #

# Define the base directory

BASE_DIR = Path('Your own path here')

# Define paths for data and models
DATA_FILE = BASE_DIR / 'microplastics.txt'
MODEL_PATH = BASE_DIR / 'model/NeuML/pubmedbert-base-embeddings'
OUTPUT_DIR = BASE_DIR

# Ensure the output directory exists
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

# Download necessary NLTK data resources if not already downloaded
try:
    nltk.data.find('tokenizers/punkt')
except LookupError:
    nltk.download('punkt')

try:
    nltk.data.find('corpora/stopwords')
except LookupError:
    nltk.download('stopwords')

# ---------------------------- Data Loading ---------------------------- #

# Load documents from the specified file
try:
    with DATA_FILE.open('r', encoding='utf-8') as file:
        docs = file.read().splitlines()
    print(f'Number of documents: {len(docs)}')
    print('Preview of first 5 documents:')
    for idx, doc in enumerate(docs[:5], 1):
        print(f'{idx}: {doc}')
except FileNotFoundError:
    print(f"Error: File {DATA_FILE} not found")
    exit(1)

# ---------------------------- Custom Stopwords Loading ---------------------------- #

# Define a list of custom stopwords
custom_stopwords_file = BASE_DIR / 'custom_stopwords.txt'
try:
 with custom_stopwords_file.open('r', encoding='utf-8') as f:
      custom_stopwords = f.read().splitlines()
except FileNotFoundError:
    print(f"Error: Custom stopwords file {custom_stopwords_file} not found")
    custom_stopwords = []

# ---------------------------- Text Preprocessing ---------------------------- #

# Initialize English stopwords and add custom stopwords
stop_words = set(stopwords.words('english'))
stop_words.update(custom_stopwords)  # Add custom stopwords to the stopwords set

def preprocess_document(doc):
    """
    Preprocess a single document:
    1. Convert to lowercase
    2. Tokenize
    3. Remove stopwords and non-alphanumeric tokens
    """
    tokens = word_tokenize(doc.lower())  # Convert to lowercase and tokenize
    return [word for word in tokens if word.isalnum() and word not in stop_words]

# Preprocess all documents
tokenized_docs = [preprocess_document(doc) for doc in docs]

print("\nPreview of first 5 preprocessed documents:")
for idx, tokens in enumerate(tokenized_docs[:5], 1):
    print(f'{idx}: {tokens}')

# Rejoin tokens into cleaned documents for embedding generation
cleaned_docs = [' '.join(tokens) for tokens in tokenized_docs]

# ---------------------------- Embedding Generation ---------------------------- #

# Load the SentenceTransformer model
try:
    embedding_model = SentenceTransformer(str(MODEL_PATH))
except Exception as e:
    print(f"Error loading SentenceTransformer model: {e}")
    exit(1)

# Generate embeddings with a progress bar
embeddings = embedding_model.encode(cleaned_docs, show_progress_bar=True)
print(f"\nShape of embeddings: {embeddings.shape}")

# ---------------------------- Topic Modeling with BERTopic ---------------------------- #

# Initialize UMAP for dimensionality reduction
umap_model = umap.UMAP(
    n_neighbors=15,
    n_components=5,
    min_dist=0.0,
    metric='cosine',
    random_state=30  # Ensure reproducibility
)

# Initialize HDBSCAN for clustering
hdbscan_model = hdbscan.HDBSCAN(
    min_cluster_size=10,
    min_samples=5,
    metric='euclidean'
)

# Initialize CountVectorizer for topic representation
vectorizer_model = CountVectorizer(stop_words='english')  # Note: Stopwords already handled in preprocessing; adjust as needed

# Initialize BERTopic model
topic_model = BERTopic(
    embedding_model=embedding_model,
    umap_model=umap_model,
    hdbscan_model=hdbscan_model,
    vectorizer_model=vectorizer_model,
    verbose=True
)

# Fit BERTopic model and transform documents
topics, probs = topic_model.fit_transform(cleaned_docs, embeddings)

# Display topic information
print("\nTopic Results:")
print(topic_model.get_topic_info())

# ---------------------------- Visualization ---------------------------- #

def save_visualization(fig, name):
    """
    Save the Plotly figure as HTML and PDF files.
    """
    html_path = OUTPUT_DIR / f"{name}.html"
    pdf_path = OUTPUT_DIR / f"{name}.pdf"
    fig.write_html(str(html_path))
    fig.write_image(str(pdf_path))
    print(f"{name.capitalize()} saved as HTML: {html_path} and PDF: {pdf_path}")

# Generate and save various visualizations
visualizations = {
    "topic_barchart": topic_model.visualize_barchart(),
    "topic_distribution": topic_model.visualize_distribution(normalize_frequency=True),
    "topic_hierarchy": topic_model.visualize_hierarchy(),
    "topic_heatmap": topic_model.visualize_heatmap()
}

for name, fig in visualizations.items():
    save_visualization(fig, name)

print(f"\nAll visualization files have been saved to the directory: {OUTPUT_DIR}")
