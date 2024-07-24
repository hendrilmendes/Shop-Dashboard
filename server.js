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
    id: { type: String, unique: true, required: true },
    title: String,
    description: String,
    price: Number,
    imageUrls: [String],
    colors: [String],
    sizes: [String],
    shippingCost: Number,
    category: String,
    isOutOfStock: { type: Boolean, default: false },
    discount: { type: Number, default: 0 }
});

// Método para remover _id e substituir por id
productSchema.method('toJSON', function () {
    const { __v, _id, ...object } = this.toObject();
    object.id = _id.toString(); // Garantir que o ID seja uma string
    return object;
});

const Product = mongoose.model('Product', productSchema);

const categorySchema = new mongoose.Schema({
    id: { type: Number, unique: true, required: true },
    name: { type: String, required: true, unique: true }
});

// Método para remover _id e substituir por id
categorySchema.method('toJSON', function () {
    const { __v, _id, ...object } = this.toObject();
    object.id = _id;
    return object;
});

const Category = mongoose.model('Category', categorySchema);

app.use(bodyParser.json());
app.use(cors());

// Função para gerar um ID único
async function generateUniqueId(model) {
    const lastItem = await model.findOne().sort('-id').exec();
    return lastItem ? (parseInt(lastItem.id) + 1).toString() : '1';
}

// Endpoint para adicionar um produto
app.post('/api/products', async (req, res) => {
    const { title, description, price, imageUrls, colors, sizes, shippingCost, category, isOutOfStock } = req.body;
    try {
        const id = await generateUniqueId(Product);
        const product = new Product({
            id,
            title,
            description,
            price,
            imageUrls,
            colors,
            sizes,
            shippingCost,
            category,
            isOutOfStock,
            discount
        });
        await product.save();
        res.status(201).json(product);
    } catch (error) {
        res.status(500).json({ message: 'Erro ao adicionar produto', error });
    }
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
        const id = await generateUniqueId(Category);
        const newCategory = new Category({ id, name: category });
        await newCategory.save();
        res.status(201).json({ message: 'Categoria adicionada com sucesso!' });
    } catch (error) {
        res.status(500).json({ message: 'Erro ao adicionar categoria', error });
    }
});

// Endpoint para atualizar um produto
app.put('/api/products/:id', async (req, res) => {
    const { id } = req.params;
    const { title, description, price, imageUrls, colors, sizes, shippingCost, category, isOutOfStock, discount } = req.body;

    try {

        // 1. Construa os dados de atualização usando o operador $set
        const updateData = { $set: { title, description, price, imageUrls, colors, sizes, shippingCost, category, isOutOfStock, discount } };

        // 2. Atualiza o produto usando findByIdAndUpdate
        const updatedProduct = await Product.findByIdAndUpdate(
            id, // Usa o string ID diretamente
            updateData,
            { new: true, runValidators: true }
        );

        if (!updatedProduct) {
            return res.status(404).json({ message: 'Produto não encontrado' });
        }

        res.status(200).json(updatedProduct);
    } catch (error) {
        console.error('Erro ao atualizar produto:', error);
        res.status(500).json({ message: 'Erro ao atualizar produto', error });
    }
});

// Endpoint para buscar um produto por ID
app.get('/api/products/:id', async (req, res) => {
    const { id } = req.params;

    try {
        const product = await Product.findById(id); // Use findById for Mongoose ID
        if (!product) {
            return res.status(404).json({ message: 'Produto não encontrado' });
        }
        res.status(200).json(product);
    } catch (error) {
        console.error('Erro ao buscar produto:', error);
        res.status(500).json({ message: 'Erro ao buscar produto', error });
    }
});

// Endpoint para excluir um produto
app.delete('/api/products/:id', async (req, res) => {
    const { id } = req.params;

    try {
        const deletedProduct = await Product.findByIdAndDelete(id);
        if (!deletedProduct) {
            return res.status(404).json({ message: 'Produto não encontrado' });
        }
        res.status(200).json({ message: 'Produto excluído com sucesso!' });
    } catch (error) {
        console.error('Erro ao excluir produto:', error);
        res.status(500).json({ message: 'Erro ao excluir produto', error });
    }
});


// Endpoint para limpar tudo
app.delete('/api/clear', async (req, res) => {
    try {
        await Product.deleteMany({});
        await Category.deleteMany({});
        res.status(200).json({ message: 'Todas as coleções foram limpas com sucesso!' });
    } catch (error) {
        res.status(500).json({ message: 'Erro ao limpar coleções', error });
    }
});

app.listen(port, () => {
    console.log(`Server running at http://localhost:${port}`);
});
