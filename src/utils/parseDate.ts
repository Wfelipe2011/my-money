export function parseDate(dateStr: string, referenceDate?: string): Date {
    // Primeiro analisamos a data de referência (se fornecida)
    const reference = referenceDate ? parseSingleDate(referenceDate) : new Date();

    // Analisamos a data principal
    return parseSingleDate(dateStr, reference);
}

function parseSingleDate(dateStr: string, reference: Date = new Date()): Date {
    dateStr = dateStr.trim();

    // Verificar formato YYYY-MM-DD
    const ymdRegex = /^(\d{4})-(\d{1,2})-(\d{1,2})$/;
    if (ymdRegex.test(dateStr)) {
        const [, year, month, day] = ymdRegex.exec(dateStr)!.map(Number);
        return createValidDate(year, month - 1, day);
    }

    // Verificar formato MM-DD
    const mdRegex = /^(\d{1,2})-(\d{1,2})$/;
    if (mdRegex.test(dateStr)) {
        const [, month, day] = mdRegex.exec(dateStr)!.map(Number);
        return createValidDate(reference.getFullYear(), month - 1, day);
    }

    // Verificar formato DD/MM/YYYY
    const dmyRegex = /^(\d{1,2})\/(\d{1,2})\/(\d{4})$/;
    if (dmyRegex.test(dateStr)) {
        const [, day, month, year] = dmyRegex.exec(dateStr)!.map(Number);
        return createValidDate(year, month - 1, day);
    }

    // Verificar formato DD/MM
    const dmRegex = /^(\d{1,2})\/(\d{1,2})$/;
    if (dmRegex.test(dateStr)) {
        const [, day, month] = dmRegex.exec(dateStr)!.map(Number);
        return createValidDate(reference.getFullYear(), month - 1, day);
    }

    throw new Error(`Formato de data não suportado: ${dateStr}`);
}

function createValidDate(year: number, month: number, day: number): Date {
    const date = new Date(year, month, day);

    // Verificar se a data é válida
    if (
        date.getFullYear() !== year ||
        date.getMonth() !== month ||
        date.getDate() !== day
    ) {
        throw new Error(`Data inválida: ${year}-${month + 1}-${day}`);
    }

    return date;
}