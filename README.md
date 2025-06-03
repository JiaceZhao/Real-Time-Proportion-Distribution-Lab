# Real-Time Proportion Distribution Lab

A beautiful, interactive Vue.js application for exploring sample proportion distributions in real-time. Perfect for statistics education, science fair projects, or understanding the Central Limit Theorem.

## ✨ Features

- **Interactive Sampling**: Click to draw random samples and see instant results
- **Real-Time Visualization**: Watch the distribution build up as you collect more samples
- **Professional UI**: Modern, glass-morphism design with smooth animations
- **Statistical Insights**: Compare observed vs. theoretical statistics
- **Customizable Parameters**: Adjust population proportion and sample size
- **Responsive Design**: Works beautifully on all screen sizes

## 🎯 Educational Value

This tool demonstrates key statistical concepts:
- **Central Limit Theorem**: How sample proportions approach normal distribution
- **Sampling Variability**: Why individual samples vary from population parameters
- **Statistical Inference**: Understanding the relationship between samples and populations

## 🚀 Quick Start

### Prerequisites
- Node.js (version 16 or higher)
- npm or yarn package manager

### Installation

1. **Install dependencies**:
   ```bash
   npm install
   ```

2. **Start the development server**:
   ```bash
   npm run dev
   ```

3. **Open your browser** and navigate to `http://localhost:3000`

### Building for Production

```bash
npm run build
npm run preview
```

## 🎮 How to Use

1. **Set Population Proportion**: Use the slider to set the true population proportion (p)
2. **Choose Sample Size**: Select how many items to include in each sample
3. **Draw Samples**: Click "Draw Sample" to randomly select items based on your parameters
4. **Watch the Distribution**: See the histogram update in real-time as you collect more samples
5. **Compare Statistics**: Observe how your sample statistics compare to theoretical values

## 🛠 Technical Stack

- **Vue 3**: Composition API with reactive data binding
- **Chart.js**: Professional charting for data visualization
- **Tailwind CSS**: Utility-first styling with custom design system
- **Vite**: Fast build tool and development server
- **Lucide Icons**: Beautiful, consistent iconography

## 📊 Statistical Features

- Real-time histogram of sample proportions
- Theoretical normal distribution overlay
- Summary statistics (mean, standard deviation)
- Comparison with theoretical values
- Visual sample representation with animations

## 🎨 Design Philosophy

- **Minimalist**: Clean, uncluttered interface focusing on the data
- **Professional**: Suitable for academic presentations and classroom use
- **Accessible**: High contrast colors and clear typography
- **Engaging**: Smooth animations and interactive feedback

## 🔧 Customization

The application supports easy customization:
- Modify colors in `tailwind.config.js`
- Adjust animations in the CSS layer
- Add new statistical measures in the Vue components
- Extend chart types in the DistributionChart component

## 📱 Browser Support

- Chrome (recommended)
- Firefox
- Safari
- Edge

## 🤝 Contributing

This project is designed for educational use. Feel free to:
- Report issues or bugs
- Suggest new features
- Submit improvements
- Use in your own educational materials

## 📄 License

MIT License - free for educational and commercial use.

---

**Perfect for**: Statistics courses, science fair projects, data science education, and anyone wanting to understand sampling distributions visually! 