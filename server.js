const express = require('express');
const { Pool } = require('pg');
const bodyParser = require('body-parser');
const cors = require('cors');

const app = express();
const port = process.env.PORT || 3000; // Use a porta definida pela Render.com ou padrão 3000

// Configuração do PostgreSQL
const pool = new Pool({
    user: 'hendril', // Substitua pelo seu usuário PostgreSQL
    host: 'dpg-cqe7kog8fa8c73e1h6hg-a', // Substitua pelo seu host PostgreSQL
    database: 'shop_db_iq9d', // Substitua pelo seu banco de dados PostgreSQL
    password: 'sbCLNpi0RdAKFsqhk8MyqQhy6WdB1jQ5', // Substitua pela sua senha PostgreSQL
    port: process.env.PG_PORT || 5432, // Substitua pela sua porta PostgreSQL se for diferente
});

app.use(bodyParser.json());
app.use(cors());

// Endpoint para adicionar um produto
app.post('/api/products', async (req, res) => {
    const { title, description, price, imageUrls, colors, sizes, shippingCost, category } = req.body;
    try {
        const result = await pool.query(
            'INSERT INTO products (title, description, price, image_urls, colors, sizes, shipping_cost, category) VALUES ($1, $2, $3, $4, $5, $6, $7, $8) RETURNING *',
            [title, description, price, imageUrls, colors, sizes, shippingCost, category]
        );
        res.status(201).json(result.rows[0]);
    } catch (error) {
        res.status(500).json({ message: 'Erro ao adicionar produto', error });
    }
});

// Endpoint para listar todos os produtos
app.get('/api/products', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM products');
        res.status(200).json(result.rows);
    } catch (error) {
        res.status(500).json({ message: 'Erro ao buscar produtos', error });
    }
});

// Endpoint para obter categorias
app.get('/api/categories', async (req, res) => {
    try {
        const result = await pool.query('SELECT name FROM categories');
        res.status(200).json(result.rows.map(row => row.name));
    } catch (error) {
        res.status(500).json({ message: 'Erro ao buscar categorias', error });
    }
});

// Endpoint para adicionar uma nova categoria
app.post('/api/categories', async (req, res) => {
    const { category } = req.body;
    try {
        const result = await pool.query(
            'INSERT INTO categories (name) VALUES ($1) RETURNING *',
            [category]
        );
        res.status(201).json({ message: 'Categoria adicionada com sucesso!' });
    } catch (error) {
        res.status(500).json({ message: 'Erro ao adicionar categoria', error });
    }
});

// Inicialização do servidor
app.listen(port, () => {
    console.log(`Server running at http://localhost:${port}`);
});
