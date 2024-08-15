const express = require('express');
const mongoose = require('mongoose');
const bodyParser = require('body-parser');
const cors = require('cors');
const qr = require('qrcode');
const { exec } = require('child_process');
const fs = require('fs');
const path = require('path');
const multer = require('multer');

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

//Esquema de pedidos
const orderSchema = new mongoose.Schema({
    id: { type: String, unique: true, required: true },
    customerName: { type: String, required: true },
    address: { type: String, required: true },
    paymentMethod: { type: String, required: true },
    amount: { type: Number, required: true },
    date: { type: Date, default: Date.now },
    items: [
        {
            id: { type: String, required: true },
            title: { type: String, required: true },
            quantity: { type: Number, required: true },
            price: { type: Number, required: true },
            color: { type: String, required: true },
            size: { type: String, required: true }
        }
    ]
});

const Order = mongoose.model('Order', orderSchema);

app.use(bodyParser.json());
app.use(cors());

// Função para gerar um ID único
async function generateUniqueId(model) {
    const lastItem = await model.findOne().sort('-id').exec();
    return lastItem ? (parseInt(lastItem.id) + 1).toString() : '1';
}

// Endpoint para adicionar um produto
app.post('/api/products', async (req, res) => {
    const { title, description, price, imageUrls, colors, sizes, shippingCost, category, isOutOfStock, discount } = req.body;
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

// Endpoint para excluir uma categoria
app.delete('/api/categories/:name', async (req, res) => {
    const { name } = req.params;

    try {
        // Procura e exclui a categoria pelo nome
        const deletedCategory = await Category.findOneAndDelete({ name });
        if (!deletedCategory) {
            return res.status(404).json({ message: 'Categoria não encontrada' });
        }
        res.status(200).json({ message: 'Categoria excluída com sucesso!' });
    } catch (error) {
        console.error('Erro ao excluir categoria:', error);
        res.status(500).json({ message: 'Erro ao excluir categoria', error });
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

// Endpoint para listar todos os pedidos
app.get('/api/orders', async (req, res) => {
    try {
        const orders = await Order.find();
        res.status(200).json(orders);
    } catch (error) {
        res.status(500).json({ message: 'Erro ao buscar pedidos', error });
    }
});

app.post('/api/orders', async (req, res) => {
    const { customerName, address, paymentMethod, amount, items } = req.body;
    try {
        const id = new mongoose.Types.ObjectId().toString();
        const order = new Order({
            id,
            customerName,
            address,
            paymentMethod,
            amount,
            items
        });
        await order.save();
        res.status(201).json(order);
    } catch (error) {
        res.status(500).json({ message: 'Erro ao criar pedido', error });
    }
});


// Endpoint para limpar tudo
app.delete('/api/clear', async (req, res) => {
    try {
        await Product.deleteMany({});
        await Category.deleteMany({});
        res.status(200).json({ message: 'Todas os dados foram limpos com sucesso!' });
    } catch (error) {
        res.status(500).json({ message: 'Erro ao limpar coleções', error });
    }
});

// Configuração do multer para armazenamento dos arquivos
const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, 'backup/'); // Pasta onde os arquivos serão armazenados
    },
    filename: (req, file, cb) => {
        cb(null, file.originalname); // Nome original do arquivo
    }
});

const upload = multer({ storage: storage });

// Função para realizar o backup do MongoDB
app.get('/api/backup', (req, res) => {
    const backupPath = './backup';
    const dbName = 'shop';
    const timestamp = new Date().toISOString().replace(/:/g, '-');
    const backupFile = `${backupPath}/backup-${dbName}-${timestamp}.gz`;

    if (!fs.existsSync(backupPath)) {
        fs.mkdirSync(backupPath);
    }

    exec(`mongodump --db=${dbName} --archive=${backupFile} --gzip`, (error, stdout, stderr) => {
        if (error) {
            console.error('Error during backup:', error);
            return res.status(500).json({ message: 'Erro ao realizar backup', error });
        }
        res.status(200).json({ message: 'Backup realizado com sucesso', file: backupFile });
    });
});

// Função para restaurar o backup do MongoDB
app.post('/api/restore', upload.single('backupFile'), (req, res) => {
    const backupFile = req.file.path; // O caminho do arquivo de backup enviado

    console.log('Received backupFile:', backupFile);

    if (!backupFile) {
        return res.status(400).json({ message: 'Arquivo de backup não fornecido ou inválido' });
    }

    const dbName = 'shop';

    // Executa o comando de restauração
    exec(`mongorestore --db=${dbName} --archive=${backupFile} --gzip --drop`, (error, stdout, stderr) => {
        if (error) {
            console.error('Error during restore:', error);
            return res.status(500).json({ message: 'Erro ao restaurar backup', error });
        }
        // Remove o arquivo temporário após a restauração
        fs.unlink(backupFile, (err) => {
            if (err) console.error('Error deleting file:', err);
        });
        res.status(200).json({ message: 'Backup restaurado com sucesso' });
    });
});

// Endpoint para o changelog
app.get('/changelog', (req, res) => {
    const filePath = path.join(__dirname, 'CHANGELOG.md');
    fs.readFile(filePath, 'utf8', (err, data) => {
      if (err) {
        res.status(500).send('Erro ao ler o changelog.');
        return;
      }
      res.send(data);
    });
  });
app.listen(port, () => {
    console.log(`Server running at http://localhost:${port}`);
});
