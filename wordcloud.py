import os
import pandas as pd
from wordcloud import WordCloud
import matplotlib.pyplot as plt

# Change the current working directory to the specified path
os.chdir("C:\\Users\\xiefavofan\\CTD")

# Read and process the data
df = pd.read_csv('genes.csv')

# Create a copy of the DataFrame
df_split_rows = df.copy()

# Split the 'Cited Genes' column by '|' and stack the resulting DataFrame to have one gene per row
df_split_rows = df_split_rows['Cited Genes'].str.split('|', expand=True).stack().reset_index(drop=True)

# Combine all genes into a single string separated by spaces
all_genes = ' '.join(df_split_rows)

# Generate a word cloud from the combined gene string
wordcloud = WordCloud(width=800, height=400, background_color='white').generate(all_genes)

# Display the word cloud image
plt.figure(figsize=(10, 5))
plt.imshow(wordcloud, interpolation='bilinear')
plt.axis('off')  # Hide the axis
plt.show()
