const express = require('express');
const mongoose = require('mongoose');
const bodyParser = require('body-parser');
const cors = require('cors');

const app = express();
const port = 3000;

mongoose.connect('mongodb://localhost:27017/shop')
    .then(() => console.log('MongoDB connected successfully'))
    .catch(err => {
        console.error('MongoDB connection error:', err);
        process.exit(1);
    });

const productSchema = new mongoose.Schema({
    title: String,
    description: String,
    price: Number,
    imageUrls: [String],
    colors: [String],
    sizes: [String],
    shippingCost: Number,
    category: String,
});

const Product = mongoose.model('Product', productSchema);

const categorySchema = new mongoose.Schema({
    name: { type: String, required: true, unique: true }
});

const Category = mongoose.model('Category', categorySchema);

app.use(bodyParser.json());
app.use(cors());

// Endpoint para adicionar um produto
app.post('/api/products', async (req, res) => {
    const { title, description, price, imageUrls, colors, sizes, shippingCost, category } = req.body;
    const product = new Product({
        title,
        description,
        price,
        imageUrls,
        colors,
        sizes,
        shippingCost,
        category,
    });
    await product.save();
    res.status(201).json(product);
});

// Endpoint para listar todos os produtos
app.get('/api/products', async (req, res) => {
    try {
        const products = await Product.find();
        res.status(200).json(products);
    } catch (error) {
        res.status(500).json({ message: 'Erro ao buscar produtos', error });
    }
});

// Endpoint para obter categorias
app.get('/api/categories', async (req, res) => {
    try {
        const categories = await Category.find().select('name');
        res.status(200).json(categories.map(cat => cat.name));
    } catch (error) {
        res.status(500).json({ message: 'Erro ao buscar categorias', error });
    }
});

// Endpoint para adicionar uma nova categoria
app.post('/api/categories', async (req, res) => {
    const { category } = req.body;
    try {
        const newCategory = new Category({ name: category });
        await newCategory.save();
        res.status(201).json({ message: 'Categoria adicionada com sucesso!' });
    } catch (error) {
        res.status(500).json({ message: 'Erro ao adicionar categoria', error });
    }
});

app.listen(port, () => {
    console.log(`Server running at http://localhost:${port}`);
});
